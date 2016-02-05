---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

{-# LANGUAGE ConstraintKinds  #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TemplateHaskell  #-}

module Luna.DEP.Pass.Transform.AST.Desugar.ImplicitScopes.State where

import           Luna.DEP.AST.AST          (ID)
import           Luna.DEP.Data.AliasInfo   (AliasInfo)

import           Luna.DEP.Data.ASTInfo     (ASTInfo)
import qualified Luna.DEP.Data.ASTInfo     as ASTInfo

import           Flowbox.Prelude           hiding (id)
import           Flowbox.System.Log.Logger hiding (info)

import           Control.Monad.State       (MonadState, get, modify)

logger :: Logger
logger = getLogger $moduleName


data State = State { _astInfo   :: ASTInfo
                   , _aliasInfo :: AliasInfo
                   }
           deriving (Show)

makeLenses (''State)

type StateM m = (MonadState State m, Applicative m)


getAstInfo :: StateM m => m ASTInfo
getAstInfo = view astInfo <$> get


getAliasInfo :: StateM m => m AliasInfo
getAliasInfo = view aliasInfo <$> get


--mkScope id = do
--    info <- getAliasInfo
--    let parentMap = info ^. AliasInfo.parentMap
--        astMap    = info ^. AliasInfo.astMap
--        mpid      = parentMap ^. at id
--        mpAST     = fmap (\pid -> astMap ^. at pid) mpid
--    case mpAST of
--        Nothing   -> return ()
--        Just pAST -> case pAST of
--            _ -> return ()



incID :: StateM m => m ()
incID = modify $ (astInfo . ASTInfo.lastID) %~ (+1)

genID :: StateM m => m ID
genID = (view (astInfo . ASTInfo.lastID) <$> get) <* incID


mk :: ASTInfo -> AliasInfo -> State
mk = State

------------------------------------------------------------------------
-- Instances
------------------------------------------------------------------------

--instance Default DesugarState where
--    def = DesugarState def
