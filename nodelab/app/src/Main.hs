module Main where


--      _|      _|
--      _|_|    _|    _|_|    _|      _|      _|
--      _|  _|  _|  _|_|_|_|  _|      _|      _|
--      _|    _|_|  _|          _|  _|  _|  _|
--      _|      _|    _|_|_|      _|      _|



--      _|_|_|                _|
--      _|    _|  _|    _|  _|_|_|_|    _|_|
--      _|_|_|    _|    _|    _|      _|_|_|_|
--      _|    _|  _|    _|    _|      _|
--      _|_|_|      _|_|_|      _|_|    _|_|_|
--                      _|
--                  _|_|

--        _|_|                    _|
--      _|    _|  _|  _|_|    _|_|_|    _|_|    _|  _|_|
--      _|    _|  _|_|      _|    _|  _|_|_|_|  _|_|
--      _|    _|  _|        _|    _|  _|        _|
--        _|_|    _|          _|_|_|    _|_|_|  _|


-- http://www.network-science.de/ascii/

import qualified Data.Set                          as Set
import           Utils.PreludePlus

import           Batch.Workspace                   (Workspace)
import qualified Batch.Workspace                   as Workspace
import qualified BatchConnector.Commands           as BatchCmd
import           Control.Concurrent.MVar
import           JS.Config                         (getBackendAddress, isLoggerEnabled)
import qualified JS.GraphLocation                  as GraphLocation
import           JS.UI                             (initializeGl, render, triggerWindowResize)
import           JS.UUID                           (generateUUID)
import           JS.WebSocket                      (WebSocket, connect, getWebSocket)
import           Reactive.Commands.Command         (Command, execCommand)
import qualified Reactive.Plugins.Core.Action.Init as Init
import qualified Reactive.Plugins.Core.Network     as CoreNetwork
import qualified Reactive.Plugins.Loader.Loader    as Loader
import           Reactive.State.Global             (State, initialState)
import qualified Reactive.State.Global             as Global
import           System.Random                     (newStdGen)
import           Utils.URIParser                   (getProjectName)

import qualified Utils.Shader                      as Shader


runMainNetwork :: WebSocket -> IO ()
runMainNetwork socket = do
    initializeGl
    render
    enableLogging <- isLoggerEnabled
    -- Shader.test

    lastLocation <- GraphLocation.loadLocation

    random <- newStdGen
    projectListRequestId <- generateUUID
    let initState = initialState random & Global.workspace . Workspace.lastUILocation .~ lastLocation
                                        & Global.pendingRequests %~ Set.insert projectListRequestId
    let (initActions, initState') = execCommand Init.initialize initState
    initActions

    state <- newMVar initState'
    CoreNetwork.makeNetworkDescription socket enableLogging state
    triggerWindowResize

    BatchCmd.listProjects projectListRequestId

main :: IO ()
main = do
    maybeProjectName <- getProjectName
    let projectName = maybe "myFirstProject" id maybeProjectName
    Loader.withActiveConnection $ runMainNetwork

