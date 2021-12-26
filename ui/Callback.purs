module Callback where
import Effect
import Prelude

import Types (TabSource)

foreign import registerCallback :: (Array TabSource -> Effect Unit) -> Effect Unit
