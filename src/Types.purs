module Types where

import Data.Tuple (Tuple(..))
import Data.Maybe

type TabSource = {
  id :: Int,
  windowId :: Int,
  title :: String,
  url :: String,
  lastActivated :: Int,
  active :: Boolean
}

-- TODO: move to TabSource
foreign import favIconUrl :: (String -> Maybe String) -> (Maybe String) -> TabSource -> Maybe String

data Highlight = Highlight | NoHighlight

type Tab = {
  id :: Int,
  windowId :: Int,
  title :: String,
  titleDisplay :: Array (Tuple Highlight String),
  favIconUrl :: Maybe String,
  url :: String,
  hostname :: String,
  hostnameDisplay :: Array (Tuple Highlight String),
  isOwnWindowId :: Boolean,
  lastActivated :: Int,
  active :: Boolean
}

type TabsUpdate = {
  tabSources :: Array TabSource,
  ownWindowId :: Int
}
