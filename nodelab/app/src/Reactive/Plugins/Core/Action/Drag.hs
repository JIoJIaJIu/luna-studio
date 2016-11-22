{-# LANGUAGE TupleSections #-}
module Reactive.Plugins.Core.Action.Drag
    ( toAction
    ) where

import           Utils.PreludePlus
import           Utils.Vector

import           Object.Widget                     (WidgetFile, objectId, parent, widget, widgetPosition)

import           Control.Monad.State               ()
import           Control.Monad.Trans.Maybe

import           Event.Event
import           Event.Keyboard                    hiding (Event)
import qualified Event.Mouse                       as Mouse

import qualified Reactive.Commands.Batch           as BatchCmd
import           Reactive.Commands.Command         (Command)
import           Reactive.Commands.Graph           (allNodes, updateConnectionsForNodes, nodeIdToWidgetId)
import           Reactive.Commands.Graph.Selection (selectedNodes)
import qualified Reactive.Commands.UIRegistry      as UICmd
import qualified Reactive.State.Camera             as Camera
import           Reactive.State.Drag               (DragHistory (..))
import qualified Reactive.State.Drag               as Drag
import           Reactive.State.Global             (State)
import qualified Reactive.State.Global             as Global
import qualified Reactive.State.Graph              as Graph
import qualified Reactive.State.UIRegistry         as UIRegistry

import           Style.Layout                       (gridSize)

import           Object.Widget                     (Position)
import qualified Object.Widget                     as Widget
import           Object.Widget.Label               (Label)
import qualified Object.Widget.Node                as Model

import qualified UI.Handlers.Node                  as Node

import qualified Empire.API.Data.Node              as Node


toAction :: Event -> Maybe (Command State ())
toAction (Mouse _ (Mouse.Event Mouse.Pressed  pos Mouse.LeftButton (KeyMods _ False False False) (Just _))) = Just $ startDrag pos
toAction (Mouse _ (Mouse.Event Mouse.Moved    pos Mouse.LeftButton (KeyMods True False False False) _))        = Just $ handleMove pos False
toAction (Mouse _ (Mouse.Event Mouse.Moved    pos Mouse.LeftButton (KeyMods False  False False False) _))        = Just $ handleMove pos True
toAction (Mouse _ (Mouse.Event Mouse.Released _   Mouse.LeftButton _ _)) = Just stopDrag
toAction _ = Nothing


isNodeUnderCursor :: Command UIRegistry.State Bool
isNodeUnderCursor = isJust <$> runMaybeT act where
    act = do
        Just wid <- lift $ use UIRegistry.widgetOver
        Just w   <- lift (UIRegistry.lookupTypedM wid :: Command UIRegistry.State (Maybe (WidgetFile Model.Node)))
        return w

isNodeLabelUnderCursor :: Command UIRegistry.State Bool
isNodeLabelUnderCursor = fromMaybe False <$> runMaybeT act where
    act = do
        Just wid <- lift $ use UIRegistry.widgetOver
        Just w   <- lift (UIRegistry.lookupTypedM wid :: Command UIRegistry.State (Maybe (WidgetFile Label)))
        Just p   <- return $ w ^. parent
        Just _   <- lift (UIRegistry.lookupTypedM p :: Command UIRegistry.State (Maybe (WidgetFile Model.Node)))
        exId <- lift $ Node.expressionId p
        return $ wid == exId

getNodePosUnderCursor :: Command UIRegistry.State (Maybe Position)
getNodePosUnderCursor = runMaybeT $ do
    (Just id) <- lift $ use UIRegistry.widgetOver
    (Just w ) <- lift $ (UIRegistry.lookupTypedM id :: Command UIRegistry.State (Maybe (WidgetFile Model.Node)))
    return $ w ^. Widget.widget . Model.position

getNodePosLabelUnderCursor :: Command UIRegistry.State (Maybe Position)
getNodePosLabelUnderCursor = runMaybeT act >>= return . join where
    act = do
        (Just id) <- lift $ use UIRegistry.widgetOver
        (Just w)  <- lift $ (UIRegistry.lookupTypedM id :: Command UIRegistry.State (Maybe (WidgetFile Label)))
        (Just p)  <- return $ w ^. parent
        (Just n)  <- lift $ (UIRegistry.lookupTypedM p :: Command UIRegistry.State (Maybe (WidgetFile Model.Node)))
        exId <- lift $ Node.expressionId p
        return $ if id == exId
            then Just $ n ^. Widget.widget . Model.position
            else Nothing

startDrag :: Vector2 Int -> Command State ()
startDrag coord = do
    nodePos     <- zoom Global.uiRegistry getNodePosUnderCursor
    nodePos'    <- zoom Global.uiRegistry getNodePosLabelUnderCursor
    withJust (nodePos `mplus` nodePos') $ \widgetPos -> do
        Global.drag . Drag.history ?= DragHistory coord coord coord widgetPos

-- gridSize = 8

snapCoord :: Double -> Double
snapCoord p = fromIntegral . (* gridSize) . round $ p / fromIntegral gridSize

snap :: Vector2 Double -> Vector2 Double
snap (Vector2 x y) = Vector2 x' y' where
  x' = snapCoord x
  y' = snapCoord y

delay :: Vector2 Double -> Double -> Bool
delay (Vector2 x y) d = x < -d || x > d || y > d || y < -d


handleMove :: Vector2 Int -> Bool -> Command State ()
handleMove coord snapped = do
    factor <- use $ Global.camera . Camera.camera . Camera.factor
    dragHistory <- use $ Global.drag . Drag.history
    withJust dragHistory $ \(DragHistory start previous current widgetPos) -> do
        let delta = coord - current
            deltaWs = Camera.scaledScreenToWorkspace factor delta
            newNodePos = widgetPos + deltaWs
            newNodePosSnapped = snap newNodePos
            newDeltaWsSnapped = newNodePosSnapped - widgetPos
        if snapped then do
            when ((lengthSquared newDeltaWsSnapped > 0.1) && (delay deltaWs $ fromIntegral gridSize)) $ do
                 moveNodes newDeltaWsSnapped
                 Global.drag . Drag.history ?= DragHistory start current coord newNodePosSnapped
        else do
            moveNodes deltaWs
            Global.drag . Drag.history ?= DragHistory start current coord newNodePos

moveNodes :: Vector2 Double -> Command State ()
moveNodes delta = do
    widgets <- selectedNodes
    let selectedIdsWithPos = (\w -> (w ^. widget . Model.nodeId , w ^. widget . widgetPosition)) <$> widgets
    forM_ selectedIdsWithPos $ \(id, pos) -> do
        widgetIdMay <- nodeIdToWidgetId id
        withJust widgetIdMay $ \widgetId ->
            zoom Global.uiRegistry $ UICmd.move widgetId (pos + delta)
    updateConnectionsForNodes $ (view $ widget . Model.nodeId) <$> widgets

stopDrag :: Command State ()
stopDrag = do
    dragHistory <- use $ Global.drag . Drag.history

    withJust dragHistory $ \(DragHistory start current _ _) -> do
        Global.drag . Drag.history .= Nothing
        when (start /= current) $ do
            widgets <- allNodes

            let selected = filter (^. widget . Model.isSelected) widgets
                nodesToUpdate = (\w -> (w ^. widget . Model.nodeId, w ^. widget . widgetPosition)) <$> selected

            updates <- forM nodesToUpdate $ \(wid, pos) -> do
                Global.graph . Graph.nodesMap . ix wid . Node.position .= toTuple pos
                newMeta <- preuse $ Global.graph . Graph.nodesMap . ix wid . Node.nodeMeta
                return $ (wid, ) <$> newMeta
            BatchCmd.updateNodeMeta $ catMaybes updates
            updateConnectionsForNodes $ fst <$> nodesToUpdate
