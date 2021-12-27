module Types where

import Data.Tuple (Tuple(..))

type TabSource = {
  id :: Int,
  windowId :: Int,
  index :: Int,
  title :: String,
  favIconUrl :: String,
  url :: String
}

data Highlight = Highlight | NoHighlight

type Tab = {
  id :: Int,
  windowId :: Int,
  index :: Int,
  title :: String,
  titleDisplay :: Array (Tuple Highlight String),
  favIconUrl :: String,
  url :: String,
  hostname :: String,
  hostnameDisplay :: Array (Tuple Highlight String)
}
