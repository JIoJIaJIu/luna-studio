{-# LANGUAGE FlexibleInstances #-}
module Empire.API.JSONInstances where

import           Data.Aeson.Types                    (FromJSON, ToJSON, toJSON, parseJSON)
import           Data.Map.Lazy                       (Map)
import qualified Data.Map.Lazy                       as Map
import           Prologue

import           Empire.API.Control.EmpireStarted    as EmpireStarted
import           Empire.API.Data.Breadcrumb          as Breadcrumb
import           Empire.API.Data.Connection          as Connection
import           Empire.API.Data.DefaultValue        as DefaultValue
import           Empire.API.Data.Error               as Error
import           Empire.API.Data.Graph               as Graph
import           Empire.API.Data.GraphLocation       as GraphLocation
import           Empire.API.Data.Library             as Library
import           Empire.API.Data.Node                as Node
import           Empire.API.Data.NodeMeta            as NodeMeta
import           Empire.API.Data.Port                as Port
import           Empire.API.Data.PortRef             as PortRef
import           Empire.API.Data.Project             as Project
import           Empire.API.Data.TypeRep             as TypeRep
import           Empire.API.Data.ValueType           as ValueType
import           Empire.API.Graph.AddNode            as AddNode
import           Empire.API.Graph.CodeUpdate         as CodeUpdate
import           Empire.API.Graph.Connect            as Connect
import           Empire.API.Graph.Disconnect         as Disconnect
import           Empire.API.Graph.GetProgram         as GetProgram
import           Empire.API.Graph.NodeResultUpdate   as NodeResultUpdate
import           Empire.API.Graph.NodeSearcherUpdate as NodeSearcherUpdate
import           Empire.API.Graph.NodeUpdate         as NodeUpdate
import           Empire.API.Graph.RemoveNode         as RemoveNode
import           Empire.API.Graph.RenameNode         as RenameNode
import           Empire.API.Graph.SetDefaultValue    as SetDefaultValue
import           Empire.API.Graph.SetInputNodeType   as SetInputNodeType
import           Empire.API.Graph.UpdateNodeMeta     as UpdateNodeMeta
import           Empire.API.Library.CreateLibrary    as CreateLibrary
import           Empire.API.Library.ListLibraries    as ListLibraries
import           Empire.API.Persistence.Library      as PLibrary
import           Empire.API.Persistence.Project      as PProject
import           Empire.API.Persistence.Envelope     as PEnvelope
import           Empire.API.Project.CreateProject    as CreateProject
import           Empire.API.Project.ListProjects     as ListProjects
import           Empire.API.Update                   as Update

instance ToJSON Project.Project
instance ToJSON Library.Library

instance ToJSON Breadcrumb.Breadcrumb
instance ToJSON Breadcrumb.BreadcrumbItem
instance FromJSON Breadcrumb.Breadcrumb
instance FromJSON Breadcrumb.BreadcrumbItem

instance ToJSON GraphLocation.GraphLocation

instance ToJSON Node.Node
instance FromJSON Node.Node
instance ToJSON Node.NodeType
instance FromJSON Node.NodeType

instance ToJSON NodeMeta.NodeMeta
instance FromJSON NodeMeta.NodeMeta
instance (ToJSON a, ToJSON b) => ToJSON (Map a b) where
    toJSON = toJSON . Map.toList
    {-# INLINE toJSON #-}
instance (FromJSON b) => FromJSON  (Map PortId b) where
    parseJSON = fmap Map.fromList . parseJSON
    {-# INLINE parseJSON #-}

instance ToJSON Port.Port
instance FromJSON Port.Port
instance ToJSON Port.InPort
instance FromJSON Port.InPort
instance ToJSON Port.OutPort
instance FromJSON Port.OutPort
instance ToJSON Port.PortId
instance FromJSON Port.PortId
instance ToJSON Port.PortState
instance FromJSON Port.PortState

instance ToJSON TypeRep.TypeRep
instance FromJSON TypeRep.TypeRep

instance ToJSON ValueType.ValueType
instance FromJSON ValueType.ValueType
instance ToJSON ValueType.ValueTypeEnum

instance ToJSON PortRef.AnyPortRef
instance FromJSON PortRef.AnyPortRef
instance ToJSON PortRef.OutPortRef
instance FromJSON PortRef.OutPortRef
instance ToJSON PortRef.InPortRef
instance FromJSON PortRef.InPortRef

instance ToJSON Connection.Connection

instance ToJSON DefaultValue.Value
instance FromJSON DefaultValue.Value
instance ToJSON DefaultValue.PortDefault
instance FromJSON DefaultValue.PortDefault

instance ToJSON Graph.Graph
instance FromJSON Graph.Graph

instance ToJSON t => ToJSON (Error.Error t)

instance ToJSON AddNode.NodeType
instance ToJSON AddNode.Request
instance ToJSON AddNode.Result

instance ToJSON Connect.Request

instance ToJSON Disconnect.Request

instance ToJSON RemoveNode.Request

instance ToJSON RenameNode.Request

instance ToJSON UpdateNodeMeta.Request
instance ToJSON UpdateNodeMeta.Result

instance ToJSON NodeUpdate.Update
instance ToJSON NodeResultUpdate.Update
instance ToJSON NodeResultUpdate.NodeValue
instance ToJSON CodeUpdate.Update

instance ToJSON GetProgram.Request
instance ToJSON GetProgram.Status

instance ToJSON SetDefaultValue.Request

instance ToJSON SetInputNodeType.Request

instance ToJSON CreateLibrary.Request
instance ToJSON CreateLibrary.Result

instance ToJSON ListLibraries.Request
instance ToJSON ListLibraries.Status

instance ToJSON CreateProject.Request
instance ToJSON CreateProject.Result

instance ToJSON ListProjects.Request
instance ToJSON ListProjects.Status

instance (ToJSON req, ToJSON res) => ToJSON (Update.Update req res)
instance ToJSON Update.ResultOk

instance ToJSON NodeSearcherUpdate.Update

instance ToJSON EmpireStarted.Status

instance ToJSON PProject.Project
instance FromJSON PProject.Project
instance ToJSON PLibrary.Library
instance FromJSON PLibrary.Library
instance ToJSON PEnvelope.Envelope
instance FromJSON PEnvelope.Envelope
