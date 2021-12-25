module Main where

import Prelude
import Callback (registerCallback)
import Data.Array as Array
import Data.Foldable
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Pattern (Pattern(..)) as String
import Data.String.CodePoints (contains, indexOf) as String
import Data.String.Common (toLower, split) as String
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console as Console
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Query.Input (RefLabel(..))
import Halogen.Subscription as HS
import Halogen.VDom.Driver (runUI)
import Types (Tab)
import Web.HTML.Common (ClassName(..))
import Web.HTML.HTMLElement as HTMLElement

type State = { enabled :: Boolean,
               tabs :: Array Tab,
               sortedTabs :: Array Tab,
               searchQuery :: String,
               selectedIndex :: Int
             }

data Action = Toggle
            | Initialize
            | Tabs (Array Tab)
            | HighlightTab Tab
            | CloseTab Tab
            | UpdateSearch String
            | NoOp

component :: forall q i o m. MonadEffect m => H.Component q i o m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction, initialize = Just Initialize }
    }

initialState :: forall i. i -> State
initialState _ =
  { enabled: false,
    tabs: [],
    sortedTabs: [],
    searchQuery: "",
    selectedIndex: 0
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.id "tab-view",
      HP.tabIndex 0
      -- TODO: keydown
    ]
    [ HH.input
        [ HP.id "tab-search",
          HP.type_ HP.InputText,
          HE.onValueInput UpdateSearch,
          HP.placeholder "Type to search...",
          HP.ref (RefLabel "tabSearch")
        ],
      HH.ol
        []
        (Array.mapWithIndex (renderTab state.selectedIndex) state.sortedTabs)
    ]

renderTab :: forall m. Int -> Int -> Tab -> H.ComponentHTML Action () m
renderTab selectedIndex index tab =
  let
    iconBg = "background-image: url('" <> tab.favIconUrl <> "')"
    selected = selectedIndex == index
    cls name enable = if enable then[ ClassName name ] else []
  in
   HH.li
    [ HP.classes (cls "tab" true <> cls "selected" selected),
      HE.onClick \_ -> HighlightTab tab
    ]
    [ HH.span [ HP.class_ (ClassName "tab-close-button"), HE.onClick \_ -> CloseTab tab]
              [ HH.span [] [HH.text "close"]],
      HH.span [ HP.class_ (ClassName "tab-icon-wrap") ]
              [ HH.span
                  [ HP.class_ (ClassName "tab-icon"),
                    HP.style iconBg
                  ]
                  []
              ],
      HH.span [ HP.class_ (ClassName "tab-title") ]
              [ HH.span [] [ HH.text tab.title ] ]
    ]


handleAction :: forall o m. MonadEffect m => Action → H.HalogenM State Action () o m Unit
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

  Tabs tabs -> do
    -- H.liftEffect $ Console.log ("tabs " <> show tabs)
    H.modify_ \st -> st { tabs = tabs, sortedTabs = filterAndSort "" tabs, searchQuery = "" }

    mbEl <- H.getHTMLElementRef (RefLabel "tabSearch")
    for_ mbEl \el ->
      liftEffect $ HTMLElement.focus el
    pure unit

  HighlightTab tab ->
    pure unit

  CloseTab tab ->
    pure unit

  UpdateSearch query -> do
    H.modify_ \st -> st { sortedTabs = filterAndSort query st.tabs, searchQuery = query }


-- filterAndSort (st.searchQuery)
    -- H.liftEffect $ Console.log query
    pure unit

  NoOp -> do
    -- H.liftEffect $ Console.log "no-op"
    pure unit

filterAndSort ::  String -> Array Tab -> Array Tab
filterAndSort searchQuery tabs =
  let
    qs = String.split (String.Pattern " ") (String.toLower searchQuery)
    -- TODO: add domain to teststrings
    -- testStrings tab = [String.toLower tab.title, String.toLower tab.url]
    testStrings tab = [String.toLower tab.title]
    tabs_ = Array.filter
              (\tab ->
                  tab.title /= "Stabber"
                  && (if searchQuery == ""
                      then true
                      else Array.all
                            (\q -> Array.any (\s -> (String.contains (String.Pattern q) s)) (testStrings tab))
                            qs))
              tabs
  in tabs_

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body
