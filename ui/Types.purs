module Types where

type TabSource = {
  id :: Int,
  windowId :: Int,
  index :: Int,
  title :: String,
  favIconUrl :: String,
  url :: String
}

type Tab = {
  id :: Int,
  windowId :: Int,
  index :: Int,
  title :: String,
  favIconUrl :: String,
  url :: String,
  hostname :: String
}
