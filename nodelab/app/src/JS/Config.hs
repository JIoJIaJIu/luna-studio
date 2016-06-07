{-# LANGUAGE JavaScriptFFI     #-}
{-# LANGUAGE OverloadedStrings #-}

module JS.Config (getBackendAddress) where

import           Data.JSString     (unpack)
import           GHCJS.Types       (JSString)
import           Utils.PreludePlus


foreign import javascript safe "config.backendAddress"
    getBackendAddress' :: IO JSString

getBackendAddress :: IO String
getBackendAddress  = unpack <$> getBackendAddress'
