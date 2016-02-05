---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
{-# LANGUAGE DeriveDataTypeable    #-}
{-# LANGUAGE DeriveFoldable        #-}
{-# LANGUAGE DeriveFunctor         #-}
{-# LANGUAGE DeriveTraversable     #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE UndecidableInstances  #-}

module Flowbox.Graphics.Color.YCbCr_HD where

import           Data.Foldable                     (Foldable)
import           Data.Typeable

import           Flowbox.Graphics.Utils.Accelerate
import           Flowbox.Prelude                   hiding (lift)



data YCbCr_HD a = YCbCr_HD { ycbcr_hdY :: a, ycbcr_hdCb :: a, ycbcr_hdCr :: a }
                deriving (Foldable, Functor, Traversable, Typeable, Show)

deriveAccelerate ''YCbCr_HD
deriveEach ''YCbCr_HD
