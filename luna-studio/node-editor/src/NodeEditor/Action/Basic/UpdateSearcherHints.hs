module NodeEditor.Action.Basic.UpdateSearcherHints where

import Common.Prelude

import qualified Data.Aeson                      as Aeson
import qualified Data.ByteString.Lazy.Char8      as BS
import qualified Data.JSString                   as JSString
import qualified Data.Map                        as Map
import qualified Data.Set                        as Set
import qualified Data.Text                       as Text
import qualified IdentityString                  as IS
import qualified LunaStudio.Data.NodeSearcher    as NS
import qualified NodeEditor.React.Model.Searcher as Searcher
import qualified NodeEditor.State.Global         as Global

import Common.Action.Command                (Command)
import Common.Prelude
import Data.Set                             (Set)
import Data.Text                            (Text)
import JS.Visualizers                       (sendVisualizationData)
import LunaStudio.Data.NodeSearcher         (EntryType (Function), ImportName,
                                             ImportsHints, Match (Match),
                                             ModuleHints (ModuleHints),
                                             RawEntry (RawEntry),
                                             TypePreferation (TypePreferation),
                                             currentImports, imports,
                                             missingImports)
import LunaStudio.Data.TypeRep              (ConstructorRep (ConstructorRep))
import NodeEditor.Action.Batch              (searchNodes)
import NodeEditor.Action.State.NodeEditor   (getLocalFunctions, getSearcher,
                                             inTopLevelBreadcrumb,
                                             modifySearcher)
import NodeEditor.React.Model.Searcher      (NodeModeInfo, Searcher,
                                             allCommands, className,
                                             updateCommandsResult,
                                             updateNodeResult, waitingForTc)
import NodeEditor.React.Model.Visualization (visualizationId)
import NodeEditor.State.Global              (State, nodeSearcherData)


type IsFirstQuery         = Bool
type SearchForMethodsOnly = Bool

selectNextHint :: Searcher -> Command State ()
selectNextHint _ = modifySearcher $ use (Searcher.hints . to length)
    >>= \hintsLen -> Searcher.selected %= min hintsLen . succ

selectPreviousHint :: Searcher -> Command State ()
selectPreviousHint _
    = modifySearcher $ Searcher.selectedPosition %= max 0 . pred

selectHint :: Int -> Command State ()
selectHint i = when (i >= 0) . modifySearcher $ do
    hLen <- use $ Searcher.hints . to length
    when (i <= hLen) $ Searcher.selected .= i

localAddSearcherHints :: LibrariesHintsMap -> Command State ()
localAddSearcherHints libHints = do
    Global.nodeSearcherData . NodeSearcher.libraries %= Map.union libHints
    localUpdateSearcherHintsPreservingSelection
    Global.waitingForTc .= False
    modifySearcher $ Searcher.waitingForTc .= False

setImportedLibraries :: Set ImportName -> Command State ()
setImportedLibraries libs = do
    Global.nodeSearcherData . NodeSearcher.importedLibraries .= libs
    missingLibs <- use $ Global.nodeSearcherData . Searcher.missingLibraries
    unless (null missingLibs) $ do
        Global.waitingForTc                    .= True
        modifySearcher $ Searcher.waitingForTc .= True
        searchNodes missingLibs

updateDocumentation :: Command State ()
updateDocumentation = withJustM getSearcher $ \s -> do
    let mayDocVis = s ^. Searcher.documentationVisualization
        mayDoc = s ^? Searcher.selectedHint . _Just . Match.documentation . _Just
        mayDocData = (,) <$> mayDocVis <*> mayDoc
    withJust mayDocData $ \(docVis, doc) -> liftIO $ sendVisualizationData
        (docVis ^. Visualization.visualizationId)
        (ConstructorRep "Text" def)
        =<< (IS.fromJSString . JSString.pack . BS.unpack $ Aeson.encode doc)

localUpdateSearcherHintsPreservingSelection :: Command State ()
localUpdateSearcherHintsPreservingSelection = do
    maySelected <- maybe def (view Searcher.selectedHint) <$> getSearcher
    localUpdateSearcherHints'
    withJust maySelected $ \selected -> do
        let equalsType (Searcher.CommandHint _) (Searcher.CommandHint _) = True
            equalsType (Searcher.NodeHint    _) (Searcher.NodeHint    _) = True
            equalsType _                       _                         = False
            equalsName h1 h2 = h1 ^. Match.name == h2 ^. Match.name
            equals h1 h2 = equalsType h1 h2 && equalsName h1 h2
        hints <- maybe def (view Searcher.hints) <$> getSearcher
        withJust (findIndex (equals selected) hints) $ selectHint . (+1)
    updateDocumentation

localUpdateSearcherHints :: Command State ()
localUpdateSearcherHints = localUpdateSearcherHints' >> updateDocumentation

localUpdateSearcherHints' :: Command State ()
localUpdateSearcherHints' = unlessM inTopLevelBreadcrumb $ do
    nsData'        <- use Global.nodeSearcherData
    localFunctions <- getLocalFunctions
    let localFunctionsImportName = "Local"
        nsData :: NodeSearcherData
        nsData = nsData'
            & Searcher.libraries %~ Map.insert
                localFunctionsImportName
                (Searcher.mkLocalFunctionsLibrary localFunctions)
            & Searcher.importedLibraries %~ Set.insert localFunctionsImportName
    modifySearcher $ do
        mayQuery <- preuse $ Searcher.input . Searcher._Divided
        m        <- use Searcher.mode
        let selectInput = maybe True (Text.null . view Searcher.query) mayQuery
            (mode, hintsLen) = case m of
                (Searcher.Node _ nmi _) -> do
                    let isFirstQuery         q = Text.null
                            . Text.dropWhile (== ' ') $ q ^. Searcher.prefix
                        strippedPrefix       q = Text.dropWhileEnd (== ' ')
                            $ q ^. Searcher.prefix
                        searchForMethodsOnly q
                            =  not (Text.null $ strippedPrefix q)
                            && (Text.last (strippedPrefix q) == '.')
                        processQuery q = do
                            let query'     = q ^. Searcher.query
                                weights    = Just $ getWeights
                                    (isFirstQuery q)
                                    (searchForMethodsOnly q)
                                    nmi
                                    query'
                                searchRes' = NS.search query' nsData weights
                                searchRes  = if query' == "_"
                                    then Match
                                        (RawEntry
                                            query'
                                            def
                                            Function
                                            1000000
                                            . Just $ NS.ImportInfo
                                                localFunctionsImportName
                                                True
                                        ) True 1000000 [(0, 1)] : searchRes'
                                    else searchRes'
                            if Text.strip (q ^. Searcher.prefix) == "def"
                                then def
                                else takeWhile (view NS.exactMatch) searchRes
                        result = maybe [] processQuery mayQuery
                    (updateNodeResult result m, length result)
                Searcher.Command {} -> do
                    let searchCommands q = NS.searchCommands
                            (q ^. Searcher.query)
                            allCommands
                        result = maybe [] searchCommands mayQuery
                    (updateCommandsResult result m, length result)
                _                   -> (m, 0)
        Searcher.selected      .= if selectInput then 0 else min 1 hintsLen
        Searcher.rollbackReady .= False

localClearSearcherHints :: Command State ()
localClearSearcherHints = do
    modifySearcher $ do
        let updateMode (Searcher.CommandSearcher m)
                = Searcher.CommandSearcher mempty
            updateMode (Searcher.NodeSearcher m)
                = Searcher.NodeSearcher $ m & Searcher.nodes .~ mempty
        Searcher.selected      .= def
        Searcher.rollbackReady .= False
        Searcher.mode          %= \case
            Searcher.Command         _ -> Searcher.Command def
            Searcher.Node     nl nmi _ -> Searcher.Node nl nmi def
            Searcher.NodeName nl     _ -> Searcher.NodeName nl def
            Searcher.PortName pr     _ -> Searcher.PortName pr def
    updateDocs

getWeights :: IsFirstQuery -> SearchForMethodsOnly -> NodeModeInfo -> Text
    -> TypePreferation
getWeights _     True _   _ = TypePreferation 0 0 (def, def) 1 0
getWeights False _    _   q = TypePreferation 0.7 0.5 (def, def) 0.3
    $ if not (Text.null q) && isUpper (Text.head q) then 0.6 else 0.1
getWeights _     _    nmi q = case nmi ^. className of
    Nothing -> TypePreferation 0.5 0.7 (def, def) 0.3
        $ if not (Text.null q) && isUpper (Text.head q) then 0.9 else 0.2
    Just cn -> TypePreferation 0.2 0.3 (Set.singleton cn, 0.7) 0.5 0.1
