module OsDetails where

import Effect

type OsDetails =
  {
     screen :: String,
     browser :: String,
     browserversion :: String,
     browsermajorversion :: String,
     mobile :: String,
     os :: String,
     osversion :: String,
     cookies :: String,
     flashversion :: String
  }

foreign import osDetails :: Effect OsDetails
