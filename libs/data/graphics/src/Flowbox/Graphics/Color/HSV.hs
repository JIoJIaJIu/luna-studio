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

module Flowbox.Graphics.Color.HSV where

import           Data.Foldable                     (Foldable)
import           Data.Typeable

import           Flowbox.Graphics.Utils.Accelerate
import           Flowbox.Prelude                   hiding (lift)



data HSV a = HSV { hsvH :: a, hsvS :: a, hsvV :: a }
           deriving (Foldable, Functor, Traversable, Typeable, Show)

deriveAccelerate ''HSV
deriveEach ''HSV
