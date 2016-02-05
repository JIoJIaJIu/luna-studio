---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2015
---------------------------------------------------------------------------
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE OverloadedStrings         #-}
{-# LANGUAGE TemplateHaskell           #-}

module FlowboxData.Config.Config where

import           Control.Applicative
import qualified Control.Exception         as Exception
import qualified Data.Configurator         as Configurator
import qualified System.Environment        as Env

import           Flowbox.Prelude           hiding (error)
import           Flowbox.System.Log.Logger



logger :: LoggerIO
logger = getLoggerIO $moduleName


data Config = Config      { websocket :: Section
                          }
            deriving (Show)

data Section = Websocket   { host     :: String
                           , port     :: String
                           , pingTime :: String
                           }
             deriving (Show)


lunaRootEnv :: String
lunaRootEnv = "LUNAROOT"


load :: IO Config
load = do
    logger debug "Loading Luna configuration"
    cpath <- Exception.onException (Env.getEnv lunaRootEnv)
           $ logger error ("Luna environment not initialized.")
          *> logger error ("Environment variable '" ++ lunaRootEnv ++ "' not defined.")
          *> logger error ("Please run 'source <LUNA_INSTALL_PATH>/setup' and try again.")

    cfgFile <- Configurator.load [Configurator.Required $ cpath ++ "/config/flowbox-data.config"]

    let readConf name = Exception.onException (fromJustM =<< (Configurator.lookup cfgFile name :: IO (Maybe String)))
                      $ logger error ("Error reading config variable '" ++ show name)


    Config <$> ( Websocket <$> readConf "websocket.host"
                           <*> readConf "websocket.port"
                           <*> readConf "websocket.pingTime"
               )
