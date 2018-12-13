{-# LANGUAGE JavaScriptFFI     #-}
{-# LANGUAGE OverloadedStrings #-}

module NodeEditor.View.Searcher where

import           Common.Data.JSON                          (toJSONVal)
import           Common.Prelude
import qualified Control.Lens.Aeson                        as Lens
import           Data.Aeson                                (ToJSON (toEncoding, toJSON))
import           Data.Convert                              (Convertible (convert))
import           NodeEditor.React.Model.Searcher.Mode      (Mode)
import qualified NodeEditor.React.Model.Searcher.Mode      as Mode
import qualified NodeEditor.React.Model.Searcher.Mode.Node as ModeNode
import           NodeEditor.React.Model.Searcher           (Searcher)
import qualified NodeEditor.React.Model.Searcher           as Searcher
import           NodeEditor.View.Diff                      (DiffT, diffApply)
import           NodeEditor.View.Key                       (Key)
import           NodeEditor.React.Model.Searcher.Hint      (Hint)
import qualified NodeEditor.React.Model.Searcher.Hint      as Hint

entriesNum :: Int
entriesNum = 10

data HighlightView = HighlightView
    { _start :: Int
    , _end   :: Int
    } deriving (Generic, Show)

data EntryView = EntryView
    { _name       :: String
    , _doc        :: String
    , _className  :: String
    , _highlights :: [HighlightView]
    } deriving (Generic, Show)

data SearcherView = SearcherView
    { _key            :: Maybe Key
    , _selected       :: Int
    , _entries        :: [EntryView]
    , _input          :: Text
    , _inputSelection :: Maybe (Int, Int)
    , _targetField    :: Maybe String
    } deriving (Generic, Show)

makeLenses ''HighlightView
makeLenses ''EntryView
makeLenses ''SearcherView

instance ToJSON HighlightView where
    toEncoding = Lens.toEncoding
    toJSON = Lens.toJSON

instance ToJSON EntryView     where
    toEncoding = Lens.toEncoding
    toJSON = Lens.toJSON

instance ToJSON SearcherView  where
    toEncoding = Lens.toEncoding
    toJSON = Lens.toJSON

instance Convertible (Int, Int) HighlightView where
    convert = uncurry HighlightView

instance Convertible Searcher.Hint EntryView where
    convert m = EntryView
        {- name       -} (m ^. Hint.name . to convert)
        {- doc        -} (m ^. Hint.rawDocumentation . to convert)
        {- className  -} (m ^. Hint.prefix . to convert)
        {- highlights -} (m ^. Hint.matchedCharacters . to convert)

sliceEntries :: Searcher -> [EntryView]
sliceEntries s = slice es
    where
        es     = s ^. Searcher.hints . to convert
        toDrop = max (s ^. Searcher.selected - 1) 0
        slice  = if length es <= toDrop then id
                 else take entriesNum . drop toDrop

instance Convertible Searcher SearcherView where
    convert s = SearcherView
        {- key            -} (s ^. Searcher.mode . to nodeKey')
        {- selected       -} (s ^. Searcher.selected)
        {- entries        -} (sliceEntries s)
        {- input          -} (s ^. Searcher.inputText)
        {- inputSelection -} (s ^. Searcher.inputSelection)
        {- targetField    -} (s ^? Searcher.searcherMode . Mode._NodeSearcher . Mode.modeData . to show . to words . to head)

nodeKey' :: Searcher.Mode -> Maybe Key
nodeKey' = preview $ Mode._NodeSearcher . ModeNode.nodeLoc . to convert

foreign import javascript safe "callback.getNodeEditorView().setSearcher($1)"
    setSearcher__ :: JSVal -> IO ()

setSearcher :: MonadIO m => Maybe SearcherView -> m ()
setSearcher = liftIO . setSearcher__ <=< toJSONVal

searcherView :: MonadIO m => DiffT (Maybe Searcher) m ()
searcherView = diffApply $ setSearcher . convert
