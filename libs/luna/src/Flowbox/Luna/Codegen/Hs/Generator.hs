---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------
{-# LANGUAGE FlexibleContexts, NoMonomorphismRestriction, ConstraintKinds, TupleSections #-}

module Flowbox.Luna.Codegen.Hs.Generator where

import qualified Flowbox.Luna.Parser.AST.AST          as LAST
import qualified Flowbox.Luna.Parser.AST.Type         as Type
import           Flowbox.Luna.Parser.AST.Type           (Type)
import qualified Flowbox.Luna.Parser.AST.Constant     as LConstant
import qualified Flowbox.Luna.Codegen.Hs.AST.Expr     as Expr
import           Flowbox.Luna.Codegen.Hs.AST.Expr       (Expr)
import qualified Flowbox.Luna.Codegen.Hs.AST.Constant as Constant
import qualified Flowbox.Luna.Codegen.Hs.AST.Module   as Module
import qualified Flowbox.Luna.Codegen.Hs.AST.DataType as DataType
import qualified Flowbox.Luna.Codegen.Hs.AST.Function as Function
import qualified Flowbox.Luna.Codegen.Hs.AST.Cons     as Cons
import           Flowbox.Luna.Codegen.Hs.AST.Function   (Function)
import qualified Flowbox.Luna.Codegen.Hs.GenState     as GenState
import           Flowbox.Luna.Codegen.Hs.GenState       (GenState)

import           Control.Monad.State                    
import           Control.Applicative                    

import           Debug.Trace                            

import           Control.Monad.State                    
import           Control.Monad.Writer                   
import           Control.Monad.RWS                      
import           Control.Monad.Trans.Maybe              
import           Control.Monad.Trans.Either 
import           Data.Maybe                           (fromJust)            

import           Flowbox.System.Log.Logger              
import qualified Flowbox.System.Log.LogEntry          as LogEntry

import qualified Prelude                              as Prelude
import           Prelude                              hiding(error)

logger = getLogger "Flowbox.Luna.Codegen.Hs.Generator"

--type Generator a m r = (Functor m, MonadWriter [LogEntry.LogEntry] m) => LAST.Expr -> MaybeT m r

type Generator m = (Functor m, MonadState GenState m, MonadWriter [LogEntry.LogEntry] m)


data Mode = Write | Read

runGen f state = runRWS (runMaybeT f) 0 state

--ssa :: Generator m => Mode -> LAST.Expr -> MaybeT m LAST.Expr
ssa mode ast = case ast of
    LAST.Program    body                  -> LAST.Program <$> mapM (ssa mode) body
    LAST.Function   name signature body   -> do
                                                let (nast, _, logs) = runGen (ssaFunction mode ast) GenState.empty
                                                --runStateT (ssaFunction mode ast) GenState.empty
                                                --runStateT test GenState.empty
                                                return $ fromJust nast
    LAST.Assignment src dst               -> flip LAST.Assignment <$> ssa mode dst <*> ssa Write src
    LAST.Pattern    pat                   -> LAST.Pattern         <$> ssa mode pat
    LAST.Identifier name                  -> case mode of
                                                 Write -> LAST.Identifier <$> GenState.handleVar name
                                                 Read  -> do
                                                     v <- GenState.lookupVar name
                                                     case v of
                                                        Nothing      -> (logger.error $ "Not in scope: '" ++ name ++ "'") >> Prelude.fail "a"
                                                        Just newname -> return $ LAST.Identifier newname
    LAST.Operator   name src dst          -> LAST.Operator name <$> ssa mode src <*> ssa mode dst
    _                                     -> return ast


test = do
    --GenState.registerVar ("x", "x")
    return ()

--ssaFunction :: Generator m => Mode -> LAST.Expr -> MaybeT m LAST.Expr
ssaFunction mode ast@(LAST.Function name signature body) = do
    return ()
    GenState.registerVar (name, name)
    ssaType signature
    LAST.Function name signature <$> mapM (ssa mode) body


ssaType ast = case ast of
    Type.Lambda inputs outputs -> ssaType inputs
    Type.Tuple  items          -> mapM ssaType items *> return ()
    Type.Type   name           -> GenState.registerVar (name, name)

testme :: Generator m => MaybeT m ()
testme = do return ()

--genModule :: Generator a m => LAST.Expr -> MaybeT m Module
genModule ast = case ast of
    LAST.Program body -> do
                         x <- mapM genExpr body
                         return x
                         --logger.debug $ "debug"
                         --mainfunc <- genFunction $ (LAST.Function "main" [] body)
                         --return $ Module.addFunction mainfunc
                         --       $ Module.empty
                            
    --_                 -> logger.critical $ "Unknown LUNA.AST expression"

    --n <- get
    --logger.debug $ "o nie"
    ----left "err"
    --fail "oh no"
    --put $ succ n
    --return ()

--genModule ast = 
    --case ast of
    --LAST.Program  body                ->   Module.addFunction mainfunc
    --                                     $ Module.empty
    --                                     where
    --                                         mainfunc <- genFunction $ LAST.Function "main" [] body) GenState.empty
    --_                                 -> error "Unknown LUNA.AST expression"


--genFunction :: Generator a m => LAST.Expr -> MaybeT m Function
--genFunction ast = case ast of
--    LAST.Function name signature body -> Function.Function name [] <$> mapM genExpr body


--genDataType :: Generator a m => LAST.Expr -> MaybeT m Expr
--genDataType expr = case expr of
--    LAST.Typed t (LAST.Identifier ident) -> 


genExpr :: Generator m => LAST.Expr -> MaybeT m Expr
genExpr ast = case ast of
    LAST.Constant   cst                 -> case cst of
                                               LConstant.Integer val -> return $ Expr.Constant $ Constant.Integer val
                                               _                     -> logger.criticalFail $ "Unknown LUNA.AST expression"
    LAST.Identifier name                -> return $ Expr.Var ("v''" ++ name)

    LAST.Function   name signature body -> do
                                           lambda <- genType signature
                                           body'  <- mapM genExpr body
                                           return $ lambda { Expr.name = name
                                                           , Expr.body = body'
                                                           }
                                            --Expr.Function name <$> return [] <*> mapM genExpr body
    LAST.Class      cls fields methods  -> do
                                           efields <- mapM genField fields
                                           let name = Type.name cls
                                               cons = Cons.empty { Expr.name   = name 
                                                                 , Expr.fields = efields
                                                                 }
                                           return $ DataType.empty { Expr.name         = name
                                                                   , Expr.params       = Type.params cls
                                                                   , Expr.constructors = [cons]
                                                                   }  
                                            
genType :: Generator m => Type -> MaybeT m Expr
genType t = case t of
    Type.Type   name             -> return $ Expr.Var ("v''" ++ name)
    Type.Tuple  items            -> Expr.Tuple <$> mapM genType items
    Type.Lambda inputs outputs   -> do
                                    inputs'        <- Expr.items <$> genType inputs
                                    return $ Expr.Function "" inputs' []

genField :: Generator m => LAST.Expr -> MaybeT m Expr
genField (LAST.Field name t) = return $ Expr.Typed (Type.name t) (Expr.Var name)



    -- Class name params []
    --LAST.Operator   name src dst -> Expr.Operator name <$> genExpr src <*> genExpr dst
    ----LAST.Identifier name         -> do
    --                                    --vname <- GenState.genVarName
    --                                    --return $ Expr.Var vname
    ----LAST.Assignment src dst      -> do
    --                                    --dst' <- genExpr dst
    --                                    --src' <- GenState.genVarName
    --                                    --GenState.registerVar src' src
    --                                    --return $ Expr.Assignment (Expr.Var src') dst' Expr.Pure
    --_ -> return Expr.NOP




--data X a b c = X{a::a,b::b,c::c} | Y

