{-# LANGUAGE OverloadedStrings #-}

module UI.Widget.Port where

import           Utils.PreludePlus

import           GHCJS.Marshal.Pure           (PFromJSVal (..), PToJSVal (..))
import           GHCJS.Types                  (JSVal)

import           Object.UITypes
import           Object.Widget
import qualified Object.Widget.Port           as Model

import           Reactive.Commands.Command    (Command)
import qualified Reactive.Commands.UIRegistry as UICmd
import           Reactive.State.Global        (inRegistry)
import qualified Reactive.State.Global        as Global

import qualified UI.Registry                  as UIR
import           UI.Widget                    (UIWidget)
import           UI.Widget                    (GenericWidget (..))
import qualified UI.Widget                    as Widget
import qualified UI.Handlers.Node             as Node

import           Empire.API.Data.Port (InPort (Self))
import           Empire.API.Data.PortRef (AnyPortRef (InPortRef'), InPortRef(..))

newtype Port = Port { unPort :: JSVal } deriving (PToJSVal, PFromJSVal)

instance UIWidget Port

foreign import javascript safe "new Port($1, $2)"        create'      :: WidgetId -> Bool   -> IO Port
foreign import javascript safe "$1.setAngle($2, $3, $4)" setAngle     :: Port     -> Double -> Int -> Bool -> IO ()
foreign import javascript safe "$1.setColor($2)"         setColor     :: Port     -> Int    -> IO ()
foreign import javascript safe "$1.setHighlight($2)"     setHighlight :: Port     -> Bool   -> IO ()


isSelf :: AnyPortRef -> Bool
isSelf (InPortRef' (InPortRef _ Self)) = True
isSelf _ = False

create :: WidgetId -> Model.Port -> IO Port
create id model = do
    port <- create' id (isSelf $ model ^. Model.portRef)
    setAngle port (model ^. Model.angle) (model ^. Model.portCount) (model ^. Model.isOnly)
    setColor port $ model ^. Model.color
    setHighlight port $ model ^. Model.highlight
    return port

instance UIDisplayObject Model.Port where
    createUI parentId id model = do
        widget  <- create id model
        parent  <- UIR.lookup parentId :: IO GenericWidget
        UIR.register id widget
        Widget.add widget  parent

    updateUI id old model = do
        port <- UIR.lookup id :: IO Port
        setAngle port (model ^. Model.angle) (model ^. Model.portCount) (model ^. Model.isOnly)
        setColor port $ model ^. Model.color
        setHighlight port $ model ^. Model.highlight

onMouseOver, onMouseOut :: WidgetId -> Command Global.State ()
onMouseOver id = inRegistry $ do
    UICmd.update_ id $ Model.highlight .~ True
    nodeId <- UICmd.parent id
    Node.showHidePortLabels True nodeId
onMouseOut  id = inRegistry $ do
    UICmd.update_ id $ Model.highlight .~ False
    nodeId <- UICmd.parent id
    Node.showHidePortLabels False nodeId

selectNode evt _ id = do
    nid <- inRegistry $ UICmd.parent id
    Node.selectNode evt nid

widgetHandlers :: UIHandlers Global.State
widgetHandlers = def & mouseOver .~ const onMouseOver
                     & mouseOut  .~ const onMouseOut
                     & mousePressed .~ selectNode

instance CompositeWidget Model.Port
instance ResizableWidget Model.Port
