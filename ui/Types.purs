module Types where

import Data.Tuple (Tuple(..))
import Data.Maybe

type TabSource = {
  id :: Int,
  windowId :: Int,
  title :: String,
  url :: String
}

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
  hostnameDisplay :: Array (Tuple Highlight String)
}
