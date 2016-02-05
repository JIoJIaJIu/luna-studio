---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------
module Flowbox.RepoManager.Data.Package.Family where

import qualified Data.Map                                 as Map
import           Flowbox.Prelude
import qualified Flowbox.RepoManager.Data.Package.Package as Package
import qualified Flowbox.RepoManager.Data.Types           as Types
import qualified Flowbox.RepoManager.Data.Version         as Version

data PackageFamily = PackageFamily { name     :: Types.QualifiedPackageName
                                   , versions :: Map.Map Version.Version Package.Package
                                   } deriving Show
