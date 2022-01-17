module ExtInterface where
import Effect
import Prelude

import Types (TabsUpdate)

foreign import registerCallback :: (TabsUpdate -> Effect Unit) -> Effect Unit

foreign import switchToTab :: Int -> Effect Unit

foreign import closeTab :: Int -> Effect Unit
