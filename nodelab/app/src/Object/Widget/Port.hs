module Object.Widget.Port where

import           Data.Aeson               (ToJSON)
import           Utils.Angle              (toAngle)
import           Utils.PreludePlus
import           Utils.Vector

import           Empire.API.Data.PortRef  (AnyPortRef)
import qualified Empire.API.JSONInstances ()

import           Object.Widget

data Port = Port { _portRef     :: AnyPortRef
                 , _angleVector :: Vector2 Double
                 , _portCount   :: Int
                 , _isOnly      :: Bool
                 , _color       :: Int
                 , _highlight   :: Bool
                 } deriving (Eq, Show, Typeable, Generic)

makeLenses ''Port
instance ToJSON Port

angle :: Getter Port Double
angle = to (toAngle . view angleVector )

instance IsDisplayObject Port where
    widgetPosition = lens (\_ -> Vector2 0.0 0.0) (error "Port has no position setter")
    widgetSize     = lens get set where
        get _      = Vector2 0.0 0.0
        set w _    = w
    widgetVisible  = to $ const True
