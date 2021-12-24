module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Subscription as HS
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Callback (registerCallback)
import Effect.Console as Console
import Types (Tab)

type State = { enabled :: Boolean }

data Action = Toggle | Initialize | Tabs (Array Tab)

component :: forall q i o m. MonadEffect m => H.Component q i o m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction, initialize = Just Initialize }
    }

initialState :: forall i. i -> State
initialState _ = { enabled: false }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  let
    label = if state.enabled then "On!!!" else "Off"
  in
    HH.button
      [ HP.title label
      , HE.onClick \_ -> Toggle
      ]
      [ HH.text label ]

handleAction ∷ forall o m. MonadEffect m => Action → H.HalogenM State Action () o m Unit
handleAction = case _ of
  Initialize -> do
    { emitter, listener } <- H.liftEffect HS.create
    liftEffect $ registerCallback (\tabs -> do
      Console.log "callback is being called"
      HS.notify listener (Tabs tabs))
    _ <- H.subscribe emitter
    pure unit

  Toggle ->
    H.modify_ \st -> st { enabled = not st.enabled }

  Tabs tabs ->
    H.liftEffect $ Console.log ("tabs " <> show tabs)


main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body
