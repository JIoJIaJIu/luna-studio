---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
{-# LANGUAGE ConstraintKinds       #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Flowbox.AWS.EC2.EC2 (
    module EC2,
    EC2Resource,
    runEC2,
    runEC2inRegion,
) where

import qualified AWS
import           AWS.EC2                      hiding (runEC2)
import qualified AWS.EC2                      as EC2
import           Control.Monad.IO.Class       (MonadIO)
import qualified Control.Monad.Trans.Resource as Resource

import           Flowbox.AWS.Region           (Region)
import qualified Flowbox.AWS.Region           as Region
import           Flowbox.Prelude



type EC2Resource m = (MonadIO m, Resource.MonadResource m, Resource.MonadBaseControl IO m)


runEC2 :: (MonadIO m, Resource.MonadBaseControl IO m)
       => AWS.Credential -> EC2 (Resource.ResourceT m) a -> m a
runEC2 credential = Resource.runResourceT . EC2.runEC2 credential


runEC2inRegion :: (MonadIO m, Resource.MonadBaseControl IO m, Resource.MonadThrow m)
               => AWS.Credential -> Region -> EC2 (Resource.ResourceT m) a -> m a
runEC2inRegion credential region fun = runEC2 credential $ do EC2.setRegion $ Region.toText region
                                                              fun
