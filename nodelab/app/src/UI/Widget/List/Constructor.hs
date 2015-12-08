{-# LANGUAGE OverloadedStrings #-}

module UI.Widget.List.Constructor where

import           Utils.PreludePlus
import           Utils.Vector
import           Object.Widget
import           Object.UITypes
import qualified Data.Text.Lazy as Text

import qualified Reactive.Commands.UIRegistry as UICmd
import qualified Reactive.State.UIRegistry    as UIRegistry
import qualified Reactive.State.Global        as Global
import           Reactive.State.Global (inRegistry)
import           Reactive.Commands.Command (Command)

import           Data.HMap.Lazy (HTMap)
import           Data.HMap.Lazy (TypeKey(..))
import           Object.LunaValue
import           Object.LunaValue.Instances
import           Object.Widget.CompositeWidget (CompositeWidget, createWidget, updateWidget)
import           Object.Widget.List  (List(..))
import           Reactive.State.UIRegistry (addHandler)
import           UI.Generic (takeFocus, startDrag)
import           UI.Layout as Layout
import           UI.Widget.List ()
import           UI.Widget.Toggle ()
import qualified Data.HMap.Lazy as HMap
import qualified Object.Widget.Button  as Button
import qualified Object.Widget.Group   as Group
import qualified Object.Widget.Label   as Label
import qualified Object.Widget.List    as List
import qualified Object.Widget.List    as List
import qualified Object.Widget.TextBox as TextBox
import           UI.Widget.Group       ()
import           UI.Widget.Button      ()
import           UI.Widget.Label       ()
import qualified UI.Handlers.Button    as Button
import qualified UI.Handlers.TextBox   as TextBox
import           UI.Handlers.Generic   (triggerValueChanged, ValueChangedHandler(..))




deleteNth n xs = take n xs ++ drop (n+1) xs


addItemHandlers :: WidgetId -> WidgetId -> HTMap
addItemHandlers listId groupId = addHandler (Button.ClickedHandler $ addItemHandler)
                               $ mempty where
              addItemHandler _ = inRegistry $ addNewElement listId groupId

removeItemHandlers :: WidgetId -> WidgetId -> WidgetId -> HTMap
removeItemHandlers listId groupId rowId = addHandler (Button.ClickedHandler $ removeItemHandler)
                                        $ mempty where
    removeItemHandler _ = inRegistry $ removeElementByWidgetId listId groupId rowId

listItemHandler :: WidgetId -> WidgetId -> WidgetId -> AnyLunaValue -> WidgetId -> Command Global.State ()
listItemHandler listWidget groupId rowId val id = do
    inRegistry $ do
        items <- UICmd.children groupId
        let idx = elemIndex rowId items
        forM_ idx $ \idx -> UICmd.update_ listWidget $ List.value . ix idx .~ val
    newContent <- inRegistry $ UICmd.get listWidget List.value
    triggerValueChanged newContent listWidget

makeItem :: Bool -> WidgetId -> WidgetId -> AnyLunaValue -> Int -> Command UIRegistry.State ()
makeItem isTuple listId listGroupId elem ix = do
    let removeButton = Button.create (Vector2 20 20) "x"
    groupId <- UICmd.register listGroupId Group.create def
    createValueWidget groupId elem (Text.pack $ show ix) (addHandler (ValueChangedHandler $ listItemHandler listId listGroupId groupId) mempty)
    when (not isTuple) $ UICmd.register_ groupId removeButton (removeItemHandlers listId listGroupId groupId)
    Layout.horizontalLayout 0.0 groupId

makeListItem  = makeItem False
makeTupleItem = makeItem True

makeTuple :: WidgetId -> List -> Command UIRegistry.State WidgetId
makeTuple parent model = do
    contId <- UICmd.register parent model def
    groupId <- UICmd.register contId Group.create def

    let elems = (model ^. List.value) `zip` [0..]
    forM_ elems $ uncurry $ makeTupleItem contId groupId

    Layout.verticalLayout 0.0 groupId
    Layout.verticalLayout 0.0 contId

    return contId

addNewElement :: WidgetId -> WidgetId -> Command UIRegistry.State ()
addNewElement listId groupId = do
    list   <- UICmd.get listId $ List.value
    let ix = length list
    elem <- UICmd.get listId $ List.empty
    UICmd.update listId $ List.value <>~ [elem]
    makeListItem listId groupId elem ix

    Layout.verticalLayout 0.0 groupId
    Layout.verticalLayout 0.0 listId

removeElementByWidgetId :: WidgetId -> WidgetId -> WidgetId -> Command UIRegistry.State ()
removeElementByWidgetId listId groupId id = do
    items <- UICmd.children groupId
    let ix = elemIndex id items
    forM_ ix $ \ix -> removeElement listId groupId ix

removeElement :: WidgetId -> WidgetId -> Int -> Command UIRegistry.State ()
removeElement listId groupId idx = do
    UICmd.update listId $ List.value %~ deleteNth idx
    items <- UICmd.children groupId
    UICmd.removeWidget $ fromJust $ items ^? ix idx

    Layout.verticalLayout 0.0 groupId
    Layout.verticalLayout 0.0 listId


instance CompositeWidget List where
    createWidget id model = do
        let label     = Label.create "Param of list:"
            addButton = Button.create (Vector2 20 20) "+"

        UICmd.register_ id label def
        groupId     <- UICmd.register id Group.create def
        addButtonId <- UICmd.register id addButton (addItemHandlers id groupId)
        UICmd.moveX addButtonId 160

        let elems = (model ^. List.value) `zip` [0..]
        forM_ elems $ uncurry $ makeListItem id groupId

        Layout.verticalLayout 0.0 groupId
        Layout.verticalLayout 0.0 id

    updateWidget id old model = return ()
