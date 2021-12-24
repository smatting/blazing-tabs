module Callback where
import Effect
import Prelude

foreign import registerCallback :: (String -> Effect Unit) -> Effect Unit
