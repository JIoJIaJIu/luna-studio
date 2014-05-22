---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances  #-}

module Flowbox.PluginManager.Proto.Plugin where

import           Flowbox.Control.Error
import           Flowbox.PluginManager.Plugin.Info              (PluginInfo (PluginInfo))
import qualified Flowbox.PluginManager.Plugin.Info              as PluginInfo
import           Flowbox.PluginManager.Plugin.Plugin            (Plugin (Plugin))
import qualified Flowbox.PluginManager.Plugin.Plugin            as Plugin
import           Flowbox.Prelude                                hiding (id)
import           Flowbox.Tools.Serialize.Proto.Conversion.Basic
import qualified Generated.Proto.Plugin.Plugin                  as Gen
import qualified Generated.Proto.Plugin.PluginInfo              as Gen
import qualified Generated.Proto.Plugin.Status                  as Gen



instance Convert Plugin Gen.Plugin where
    encode (Plugin name command) = Gen.Plugin tname tcommand where
        tname    = encodePJ name
        tcommand = encodePJ command
    decode (Gen.Plugin mtname mtcommand) = do
        name    <- decodeP <$> mtname    <?> "Failed to decode Plugin: 'name' field is missing"
        command <- decodeP <$> mtcommand <?> "Failed to decode Plugin: 'command' field is missing"
        return $ Plugin name command


instance ConvertPure PluginInfo.Status Gen.Status where
    encodeP PluginInfo.Running = Gen.Running
    encodeP PluginInfo.Stopped = Gen.Stopped
    decodeP Gen.Running = PluginInfo.Running
    decodeP Gen.Stopped = PluginInfo.Stopped


instance Convert (Plugin.ID, PluginInfo) Gen.PluginInfo where
    encode (id, PluginInfo plugin status) = Gen.PluginInfo tid tplugin tstatus where
        tid     = encodePJ id
        tplugin = encodeJ  plugin
        tstatus = encodePJ status
    decode (Gen.PluginInfo mtid mtplugin mtstatus) = do
        id     <- decodeP <$> mtid     <?> "Failed to decode PluginInfo: 'id' field is missing"
        plugin <- decode  =<< mtplugin <?> "Failed to decode PluginInfo: 'plugin' field is missing"
        status <- decodeP <$> mtstatus <?> "Failed to decode PluginInfo: 'status' field is missing"
        return $ (id, PluginInfo plugin status)
