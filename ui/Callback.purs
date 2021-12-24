module Callback where
import Effect
import Prelude

import Types (Tab)

foreign import registerCallback :: (Array Tab -> Effect Unit) -> Effect Unit
