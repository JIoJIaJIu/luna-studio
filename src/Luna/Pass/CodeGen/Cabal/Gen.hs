---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Luna.Pass.CodeGen.Cabal.Gen where

import qualified Data.List    as List
import           Data.Version (Version)

import           Flowbox.Luna.Data.Cabal.Config  (Config)
import qualified Flowbox.Luna.Data.Cabal.Config  as Config
import           Flowbox.Luna.Data.Cabal.Section (Section)
import qualified Flowbox.Luna.Data.Cabal.Section as Section
import           Flowbox.Luna.Data.Pass.Source   (Source)
import qualified Flowbox.Luna.Data.Pass.Source   as Source
import           Flowbox.Prelude



getModuleName :: Source -> String
getModuleName source = List.intercalate "." $ Source.path source


genLibrary :: String -> Version -> [String] -> [String] -> [String] -> [Source] -> Config
genLibrary name version ghcOptions ccOptions libs sources = genCommon sectionBase name version ghcOptions ccOptions libs where
    sectionBase = Section.mkLibrary { Section.exposedModules = map getModuleName sources }


genExecutable :: String -> Version -> [String] -> [String] -> [String] -> Config
genExecutable name version ghcOptions ccOptions libs = genCommon sectionBase name version ghcOptions ccOptions libs where
    sectionBase = Section.mkExecutable name


genCommon :: Section -> String -> Version -> [String] -> [String] -> [String] -> Config
genCommon sectionBase name version ghcOptions ccOptions libs = conf where
    section = sectionBase { Section.buildDepends = libs
                          , Section.ghcOptions   = ghcOptions
                          , Section.ccOptions    = ccOptions
                          }
    conf = Config.addSection section
         $ Config.make name version
