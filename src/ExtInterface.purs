module ExtInterface where
import Effect
import Prelude

import Types (TabSource)

foreign import registerCallback :: (Array TabSource -> Effect Unit) -> Effect Unit

foreign import switchToTab :: Int -> Effect Unit

foreign import closeTab :: Int -> Effect Unit
