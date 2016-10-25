module Reactive.Commands.Graph.Render
    ( renderGraph
    ) where

import           Utils.PreludePlus

import qualified Data.HashMap.Lazy               as HashMap

import           Empire.API.Data.Input           (Input)
import           Empire.API.Data.Node            (Node)
import qualified Empire.API.Data.Node            as Node
import           Empire.API.Data.Output          (Output)
import           Empire.API.Data.PortRef         (InPortRef, OutPortRef)

import           Reactive.Commands.Command       (Command)
import           Reactive.Commands.Graph         (updateConnections, updateNodeZOrder)
import           Reactive.Commands.Graph.Connect (localConnectNodes)
import           Reactive.Commands.Node.Create   (registerNode)
import           Reactive.State.Global           (State)
import qualified Reactive.State.Global           as Global
import qualified Reactive.State.Graph            as Graph

fastAddNodes :: [Node] -> Command State ()
fastAddNodes nodes = do
    let nodeIds = (view Node.nodeId) <$> nodes
    Global.graph . Graph.nodesMap .= (HashMap.fromList $ nodeIds `zip` nodes)
    mapM_ registerNode nodes

renderGraph :: [Node] -> [(OutPortRef, InPortRef)] -> [Input] -> Output -> Command State ()
renderGraph nodes edges inputs outputs = do
    fastAddNodes nodes
    mapM_ (uncurry localConnectNodes) edges
    --TODO add to State Graph inputs outputs
    -- add inputs and outputs widgets
    updateConnections
    updateNodeZOrder
