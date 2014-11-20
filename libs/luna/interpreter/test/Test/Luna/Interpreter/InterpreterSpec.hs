---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2014
---------------------------------------------------------------------------

module Test.Luna.Interpreter.InterpreterSpec where

import Control.Monad.State hiding (mapM, mapM_)
import Test.Hspec

import           Flowbox.Prelude
import           Flowbox.System.Log.Logger
import qualified Luna.Interpreter.Session.AST.Executor             as Executor
import qualified Luna.Interpreter.Session.AST.Traverse             as Traverse
import qualified Luna.Interpreter.Session.Data.CallDataPath        as CallDataPath
import           Luna.Interpreter.Session.Data.CallPoint           (CallPoint (CallPoint))
import           Luna.Interpreter.Session.Data.CallPointPath       (CallPointPath)
import qualified Luna.Interpreter.Session.Env                      as Env
import           Luna.Interpreter.Session.Memory.Manager.NoManager (NoManager (NoManager))
import           Luna.Interpreter.Session.Session                  (Session)
import qualified Luna.Lib.Lib                                      as Library
import qualified Test.Luna.Interpreter.Common                      as Common
import qualified Test.Luna.Interpreter.SampleCodes                 as SampleCodes


rootLogger :: Logger
rootLogger = getLogger ""


getArgs :: CallPointPath -> Session mm [CallPointPath]
getArgs callPointPath = do
    mainPtr      <- Env.getMainPtr
    testCallData <- CallDataPath.fromCallPointPath callPointPath mainPtr
    args         <- Traverse.arguments testCallData
    return $ map CallDataPath.toCallPointPath args


getSuccessors :: CallPointPath -> Session mm [CallPointPath]
getSuccessors callPointPath = do
    mainPtr      <- Env.getMainPtr
    testCallData <- CallDataPath.fromCallPointPath callPointPath mainPtr
    successors   <- Traverse.next testCallData
    return $ map CallDataPath.toCallPointPath successors


main :: IO ()
main = hspec spec


shouldBe' :: (Show a, Eq a, MonadIO m) => a -> a -> m ()
shouldBe' = liftIO .: shouldBe

shouldMatchList' :: (Show a, Eq a, MonadIO m) => [a] -> [a] -> m ()
shouldMatchList' = liftIO .: shouldMatchList


spec :: Spec
spec = do
    let mm = NoManager
    describe "interpreter" $ do
        mapM_ (\(name, code) -> it ("executes example - " ++ name) $ do
            --rootLogger setIntLevel 5
            Common.runSession mm code Executor.processMain) SampleCodes.sampleCodes

        mapM_ (\(name, code) -> it ("executes example 5 times - " ++ name) $ do
            --rootLogger setIntLevel 5
            Common.runSession mm code $ replicateM_ 5 Executor.processMain) $ SampleCodes.sampleCodes

    describe "AST traverse" $ do
        it "finds function arguments" $ do
            --rootLogger setIntLevel 5
            Common.runSession mm SampleCodes.traverseExample $ do
                let lib1      = Library.ID 1
                    var_a     = [CallPoint lib1 6 ]
                    var_b     = [CallPoint lib1 10]
                    var_c     = [CallPoint lib1 21]
                    fooCall   = [CallPoint lib1 15]
                    var_e     = [CallPoint lib1 15, CallPoint lib1 36]
                    var_n     = [CallPoint lib1 15, CallPoint lib1 40]
                    var_d     = [CallPoint lib1 15, CallPoint lib1 51]
                    barCall   = [CallPoint lib1 15, CallPoint lib1 43]
                    testCall  = [CallPoint lib1 15, CallPoint lib1 43, CallPoint lib1 69]
                    tuple     = [CallPoint lib1 15, CallPoint lib1 43, CallPoint lib1 (-66)]
                    printCall = [CallPoint lib1 23]
                varAArgs  <- getArgs var_a
                varAArgs `shouldBe'` []
                varBArgs  <- getArgs var_b
                varBArgs `shouldBe'` []
                varCArgs  <- getArgs var_c
                varCArgs `shouldBe'` []
                varDArgs  <- getArgs var_d
                varDArgs `shouldBe'` []
                varEArgs  <- getArgs var_e
                varEArgs `shouldBe'` []
                varNArgs  <- getArgs var_n
                varNArgs `shouldBe'` []
                testArgs  <- getArgs testCall
                testArgs  `shouldBe'` [var_c, var_d, var_a, var_b, var_e]
                tupleArgs <- getArgs tuple
                tupleArgs `shouldBe'` [var_e, var_d, var_c, var_b, testCall, var_a]
                fooCallArgs <- getArgs fooCall
                fooCallArgs `shouldBe'` [var_a, var_b, var_c]
                barCallArgs <- getArgs barCall
                barCallArgs `shouldBe'` [var_a, var_b, var_c, var_d, var_e]
                printCallArgs <- getArgs printCall
                printCallArgs `shouldBe'` [fooCall]

        it "finds node successors" $ do
            --putStrLn =<< ppShow <$> Common.readCode SampleCodes.traverseExample
            Common.runSession mm SampleCodes.traverseExample $ do
                let lib1      = Library.ID 1
                    var_a     = [CallPoint lib1 6 ]
                    var_b     = [CallPoint lib1 10]
                    var_c     = [CallPoint lib1 21]
                    fooCall   = [CallPoint lib1 15]
                    var_e     = [CallPoint lib1 15, CallPoint lib1 36]
                    var_n     = [CallPoint lib1 15, CallPoint lib1 40]
                    var_d     = [CallPoint lib1 15, CallPoint lib1 51]
                    barCall   = [CallPoint lib1 15, CallPoint lib1 43]
                    testCall  = [CallPoint lib1 15, CallPoint lib1 43, CallPoint lib1 69]
                    tuple     = [CallPoint lib1 15, CallPoint lib1 43, CallPoint lib1 (-66)]
                    printCall = [CallPoint lib1 23]
                varASuccs  <- getSuccessors var_a
                varASuccs  `shouldMatchList'` [var_b, testCall, barCall]
                varBSuccs  <- getSuccessors var_b
                varBSuccs  `shouldMatchList'` [var_c, testCall, barCall]
                varCSuccs  <- getSuccessors var_c
                varCSuccs  `shouldMatchList'` [var_e, testCall, barCall]
                varDSuccs  <- getSuccessors var_d
                varDSuccs  `shouldMatchList'` [testCall, barCall]
                varESuccs  <- getSuccessors var_e
                varESuccs  `shouldMatchList'` [var_n, testCall, barCall]
                varNSuccs  <- getSuccessors var_n
                varNSuccs  `shouldMatchList'` [var_d]
                testCallSuccs <- getSuccessors testCall
                testCallSuccs `shouldMatchList'` [barCall]
                tupleSuccs <- getSuccessors tuple
                tupleSuccs `shouldMatchList'` [barCall]
                barCallSuccs <- getSuccessors barCall
                barCallSuccs `shouldMatchList'` [fooCall]
                fooCallSuccs <- getSuccessors fooCall
                fooCallSuccs `shouldMatchList'` [printCall]
                printCallSuccs <- getSuccessors printCall
                printCallSuccs `shouldMatchList'` [[]]
