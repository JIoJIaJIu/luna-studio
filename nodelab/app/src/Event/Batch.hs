module Event.Batch where

import           Utils.PreludePlus

import           Batch.RunStatus
import           Batch.Value
import           Empire.API.Data.Library             (Library, LibraryId)
import qualified Empire.API.Data.Library             as Library
import           Empire.API.Data.Node                (Node)
import           Empire.API.Data.PortRef             (InPortRef, OutPortRef)
import           Empire.API.Data.Project             (Project, ProjectId)
import qualified Empire.API.Data.Project             as Project

import qualified Empire.API.Graph.AddNode            as AddNode
import qualified Empire.API.Graph.CodeUpdate         as CodeUpdate
import qualified Empire.API.Graph.Connect            as Connect
import qualified Empire.API.Graph.Disconnect         as Disconnect
import qualified Empire.API.Graph.GetProgram         as GetProgram
import qualified Empire.API.Graph.NodeResultUpdate   as NodeResultUpdate
import qualified Empire.API.Graph.NodeSearcherUpdate as NodeSearcherUpdate
import qualified Empire.API.Graph.NodeUpdate         as NodeUpdate
import qualified Empire.API.Graph.RemoveNode         as RemoveNode
import qualified Empire.API.Graph.RenameNode         as RenameNode
import qualified Empire.API.Graph.UpdateNodeMeta     as UpdateNodeMeta
import           Empire.API.JSONInstances            ()
import qualified Empire.API.Project.CreateProject    as CreateProject
import qualified Empire.API.Project.ListProjects     as ListProjects
import qualified Empire.API.Project.ExportProject    as ExportProject
import qualified Empire.API.Project.ImportProject    as ImportProject
import qualified Empire.API.Control.EmpireStarted    as EmpireStarted

import           Data.Aeson                          (ToJSON)
import           Data.Int
import           Data.Text.Lazy                      (Text)

data Event = UnknownEvent String
           | AddNodeResponse                 AddNode.Response
           | NodeAdded                       AddNode.Update
           | RemoveNodeResponse           RemoveNode.Response
           | NodeRemoved                  RemoveNode.Update
           | ProgramFetched               GetProgram.Response
           | NodesConnected                  Connect.Update
           | ConnectResponse                 Connect.Response
           | NodesDisconnected            Disconnect.Update
           | DisconnectResponse           Disconnect.Response
           | NodeMetaUpdated          UpdateNodeMeta.Update
           | NodeMetaResponse         UpdateNodeMeta.Response
           | NodeRenamed                  RenameNode.Update
           | NodeRenameResponse           RenameNode.Response
           | NodeUpdated                  NodeUpdate.Update
           | CodeUpdated                  CodeUpdate.Update
           | NodeResultUpdated      NodeResultUpdate.Update
           | ProjectList                ListProjects.Response
           | ProjectCreated            CreateProject.Response
           | ProjectCreatedUpdate      CreateProject.Update
           | ProjectExported           ExportProject.Response
           | ProjectImported           ImportProject.Response
           | NodeSearcherUpdated  NodeSearcherUpdate.Update
           | EmpireStarted             EmpireStarted.Status
           | ConnectionDropped
           | ConnectionOpened
           deriving (Eq, Show, Generic)

instance ToJSON Event
