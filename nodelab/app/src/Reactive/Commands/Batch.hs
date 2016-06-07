module Reactive.Commands.Batch  where

import           Data.UUID.Types              (UUID)
import           Utils.PreludePlus

import           Batch.Workspace              (Workspace)
import qualified BatchConnector.Commands      as BatchCmd

import           Reactive.Commands.Command    (Command, performIO)
import           Reactive.Commands.UUID       (registerRequest)
import           Reactive.State.Global        (State, workspace)

import qualified Empire.API.Data.DefaultValue as DefaultValue
import           Empire.API.Data.Node         (NodeId)
import           Empire.API.Data.Project      (ProjectId)
import           Empire.API.Data.NodeMeta     (NodeMeta)
import           Empire.API.Data.PortRef      (AnyPortRef (..), InPortRef (..), OutPortRef (..))


withWorkspace :: (Workspace -> UUID -> IO ()) -> Command State ()
withWorkspace act = do
    uuid      <- registerRequest
    workspace <- use workspace
    performIO $ act workspace uuid

withUUID :: (UUID -> IO ()) -> Command State ()
withUUID act = do
    uuid <- registerRequest
    performIO $ act uuid

addNode :: Text -> NodeMeta -> Maybe NodeId -> Command State ()
addNode = withWorkspace .:. BatchCmd.addNode

createProject :: Text -> Command State ()
createProject = withUUID . BatchCmd.createProject

listProjects ::  Command State ()
listProjects = withUUID BatchCmd.listProjects

createLibrary :: Text -> Text -> Command State ()
createLibrary = withWorkspace .: BatchCmd.createLibrary

listLibraries :: ProjectId -> Command State ()
listLibraries = withUUID . BatchCmd.listLibraries

getProgram :: Command State ()
getProgram = withWorkspace BatchCmd.getProgram

updateNodeMeta :: NodeId -> NodeMeta -> Command State ()
updateNodeMeta = withWorkspace .: BatchCmd.updateNodeMeta

renameNode :: NodeId -> Text -> Command State ()
renameNode = withWorkspace .:  BatchCmd.renameNode

removeNode :: [NodeId] -> Command State ()
removeNode = withWorkspace . BatchCmd.removeNode

connectNodes :: OutPortRef -> InPortRef -> Command State ()
connectNodes = withWorkspace .: BatchCmd.connectNodes

disconnectNodes :: InPortRef -> Command State ()
disconnectNodes = withWorkspace . BatchCmd.disconnectNodes

setDefaultValue :: AnyPortRef -> DefaultValue.PortDefault -> Command State ()
setDefaultValue = withWorkspace .: BatchCmd.setDefaultValue

setInputNodeType :: NodeId -> Text -> Command State ()
setInputNodeType = withWorkspace .: BatchCmd.setInputNodeType

exportProject :: ProjectId -> Command State ()
exportProject = withUUID . BatchCmd.exportProject

importProject :: Text -> Command State ()
importProject = withUUID . BatchCmd.importProject
