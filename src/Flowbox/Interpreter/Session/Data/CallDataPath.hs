---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Flowbox.Interpreter.Session.Data.CallDataPath where

import           Flowbox.Control.Error
import qualified Flowbox.Interpreter.Session.AST.Inspect        as Inspect
import           Flowbox.Interpreter.Session.Data.CallData      (CallData (CallData))
import qualified Flowbox.Interpreter.Session.Data.CallData      as CallData
import qualified Flowbox.Interpreter.Session.Data.CallPoint     as CallPoint
import           Flowbox.Interpreter.Session.Data.CallPointPath (CallPointPath)
import           Flowbox.Interpreter.Session.Data.DefPoint      (DefPoint)
import qualified Flowbox.Interpreter.Session.Data.DefPoint      as DefPoint
import           Flowbox.Interpreter.Session.Session            (Session)
import qualified Flowbox.Interpreter.Session.Session            as Session
import qualified Flowbox.Luna.Data.AST.Common                   as AST
import           Flowbox.Luna.Data.Graph.Graph                  (Graph)
import qualified Flowbox.Luna.Data.Graph.Graph                  as Graph
import           Flowbox.Luna.Data.Graph.Node                   (Node)
import qualified Flowbox.Luna.Data.Graph.Node                   as Node
import           Flowbox.Prelude



type CallDataPath  = [CallData]


toCallPointPath :: CallDataPath -> CallPointPath
toCallPointPath = map (view CallData.callPoint)


addLevel :: CallDataPath -> DefPoint -> Session [CallDataPath]
addLevel callDataPath defPoint = do
    (graph, defID) <- Session.getGraph defPoint
    let createDataPath = append callDataPath defPoint defID graph
    return $ map createDataPath $ Graph.topsortl graph


append :: CallDataPath -> DefPoint -> AST.ID -> Graph -> (Node.ID, Node) -> CallDataPath
append callDataPath defPoint parentDefID parentGraph n =
    callDataPath ++ [CallData.mk defPoint parentDefID parentGraph n]


fromCallPointPath :: CallPointPath -> DefPoint -> Session CallDataPath
fromCallPointPath []            _              = return []
fromCallPointPath (callPoint:t) parentDefPoint = do
    (graph, defID) <- Session.getGraph parentDefPoint
    let nodeID    = callPoint ^. CallPoint.nodeID
        libraryID = callPoint ^. CallPoint.libraryID
    node <- Graph.lab graph nodeID <??> "No node with id = " ++ show nodeID
    let parentBC = parentDefPoint  ^. DefPoint.breadcrumbs
        callData = CallData callPoint parentBC defID graph node
    mdefPoint <- Inspect.fromName (node ^. Node.expr) parentBC libraryID
    (:) callData <$> case mdefPoint of
        Just defPoint -> fromCallPointPath t defPoint
        Nothing       -> return []

