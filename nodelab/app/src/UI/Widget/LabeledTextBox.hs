{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Rank2Types        #-}

module UI.Widget.LabeledTextBox where

import           Utils.PreludePlus
import           Utils.Vector
import qualified Data.Text.Lazy                as Text

import           Data.JSString.Text            (lazyTextToJSString)
import           GHCJS.Marshal.Pure            (PFromJSVal (..), PToJSVal (..))
import           GHCJS.Types                   (JSString, JSVal)

import           Object.UITypes
import           Object.Widget
import           Object.Widget.CompositeWidget (CompositeWidget, createWidget, updateWidget)
import qualified Object.Widget.LabeledTextBox  as Model

import qualified UI.Generic                    as UI
import qualified UI.Registry                   as UI
import           UI.Widget                     (UIWidget (..))
import qualified UI.Widget                     as Widget

newtype TextBox = TextBox JSVal deriving (PToJSVal, PFromJSVal)

instance UIWidget TextBox

foreign import javascript unsafe "new LabeledTextBox($1, $2, $3)"  create'           :: Int     -> Double -> Double -> IO TextBox
foreign import javascript unsafe "$1.setLabel($2)"          setLabel'         :: TextBox -> JSString         -> IO ()
foreign import javascript unsafe "$1.setValueLabel($2)"     setValueLabel'    :: TextBox -> JSString         -> IO ()
foreign import javascript unsafe "$1.startEditing($2)"      startEditing'     :: TextBox -> JSString         -> IO ()
foreign import javascript unsafe "$1.doneEditing()"         doneEditing'      :: TextBox                     -> IO ()

create :: WidgetId -> Model.LabeledTextBox -> IO TextBox
create oid model = do
    textBox      <- create' oid (model ^. Model.size . x) (model ^. Model.size . y)
    setLabel       model textBox
    setValueLabel  model textBox
    UI.setWidgetPosition (model ^. widgetPosition) textBox
    return textBox

setLabel :: Model.LabeledTextBox -> TextBox -> IO ()
setLabel model textBox = setLabel' textBox $ lazyTextToJSString $ model ^. Model.label

setValueLabel :: Model.LabeledTextBox -> TextBox -> IO ()
setValueLabel model textBox = setValueLabel' textBox $ lazyTextToJSString $ model ^. Model.value

ifChanged :: (Eq b) => a -> a -> Lens' a b -> IO () -> IO ()
ifChanged old new get action = if (old ^. get) /= (new ^. get) then action
                                                               else return ()

instance UIDisplayObject Model.LabeledTextBox where
    createUI parentId id model = do
        textBox   <- create id model
        parent   <- UI.lookup parentId :: IO Widget.GenericWidget
        UI.register id textBox
        Widget.add textBox parent

    updateUI id old model = do
        textBox <- UI.lookup id :: IO TextBox

        ifChanged old model Model.label $ setLabel       model textBox
        ifChanged old model Model.value $ setValueLabel  model textBox

        ifChanged old model Model.isEditing $ do
            if old ^. Model.isEditing then doneEditing' textBox
                                      else startEditing'  textBox $ lazyTextToJSString $ model ^. Model.value

instance CompositeWidget Model.LabeledTextBox where
    createWidget _   _ = return ()
    updateWidget _ _ _ = return ()
