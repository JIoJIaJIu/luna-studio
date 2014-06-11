---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
module Flowbox.ProjectManager.Handler.Project where

import qualified Data.Sequence as Sequence

import qualified Flowbox.Batch.Handler.Project                            as BatchP
import qualified Flowbox.Batch.Process.Map                                as ProcessMap
import           Flowbox.Batch.Project.Project                            (Project)
import qualified Flowbox.Batch.Project.Project                            as Project
import           Flowbox.Batch.Tools.Serialize.Proto.Conversion.Project   ()
import           Flowbox.Bus.RPC.RPC                                      (RPC)
import qualified Flowbox.Luna.Lib.LibManager                              as LibManager
import           Flowbox.Luna.Tools.Serialize.Proto.Conversion.Attributes ()
import           Flowbox.Prelude
import           Flowbox.ProjectManager.Context                           (ContextRef)
import qualified Flowbox.ProjectManager.Context                           as Context
import           Flowbox.System.Log.Logger
import           Flowbox.Tools.Serialize.Proto.Conversion.Basic
import qualified Generated.Proto.ProjectManager.Project.Close.Request     as Close
import qualified Generated.Proto.ProjectManager.Project.Close.Update      as Close
import qualified Generated.Proto.ProjectManager.Project.Create.Request    as Create
import qualified Generated.Proto.ProjectManager.Project.Create.Update     as Create
import qualified Generated.Proto.ProjectManager.Project.List.Request      as List
import qualified Generated.Proto.ProjectManager.Project.List.Status       as List
import qualified Generated.Proto.ProjectManager.Project.Lookup.Request    as Lookup
import qualified Generated.Proto.ProjectManager.Project.Lookup.Status     as Lookup
import qualified Generated.Proto.ProjectManager.Project.Modify.Request    as Modify
import qualified Generated.Proto.ProjectManager.Project.Modify.Update     as Modify
import qualified Generated.Proto.ProjectManager.Project.Open.Request      as Open
import qualified Generated.Proto.ProjectManager.Project.Open.Update       as Open
import qualified Generated.Proto.ProjectManager.Project.Store.Request     as Store
import qualified Generated.Proto.ProjectManager.Project.Store.Status      as Store



logger :: LoggerIO
logger = getLoggerIO "Flowbox.ProjectManager.Handler.Project"

------ public api -------------------------------------------------


list :: ContextRef -> List.Request -> RPC List.Status
list ctxRef _ = do
    projects <- Context.run ctxRef BatchP.projects
    let tprojects       = map (\a -> encode a ^. _1) projects
        tprojectsVector = Sequence.fromList tprojects
    return $ List.Status tprojectsVector


lookup :: ContextRef -> Lookup.Request -> RPC Lookup.Status
lookup ctxRef (Lookup.Request tprojectID) = do
    let projectID = decodeP tprojectID
    project <- Context.run ctxRef $ BatchP.projectByID projectID
    return $ Lookup.Status $ encode (projectID, project) ^. _1


create :: ContextRef -> Create.Request -> RPC Create.Update
create ctxRef (Create.Request tname tpath tattributes) = do
    let name = decodeP tname
        path = decodeP tpath
        attributes = decodeP tattributes
    newProject <- Context.run ctxRef $ BatchP.createProject name path attributes
    return $ Create.Update $ encode newProject ^. _1


open :: ContextRef -> Open.Request -> RPC Open.Update
open ctxRef (Open.Request tpath) = do
    let upath = decodeP tpath
    (projectID, project) <- Context.run ctxRef $ BatchP.openProject upath
    return $ Open.Update $ encode (projectID, project) ^. _1


modify :: ContextRef -> Modify.Request -> RPC Modify.Update
modify ctxRef (Modify.Request tproject) = do
    projectWithID <- decode (tproject, LibManager.empty, ProcessMap.empty) :: RPC (Project.ID, Project)
    Context.run ctxRef $ BatchP.updateProject projectWithID
    return $ Modify.Update tproject


close :: ContextRef -> Close.Request -> RPC Close.Update
close ctxRef (Close.Request tprojectID) = do
    let projectID = decodeP tprojectID
    Context.run ctxRef $ BatchP.closeProject projectID
    return $ Close.Update tprojectID


store :: ContextRef -> Store.Request -> RPC Store.Status
store ctxRef (Store.Request tprojectID) = do
    let projectID = decodeP tprojectID
    Context.run ctxRef $ BatchP.storeProject projectID
    return $ Store.Status tprojectID
