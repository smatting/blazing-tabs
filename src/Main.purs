module Main where

import ExtInterface (registerCallback, closeTab)
import ExtInterface as ExtInterface
import DOM.HTML.Indexed
import Data.Array as Array
import Data.Array.NonEmpty (head) as NonEmpty
import Data.Array.NonEmpty as NonEmpty
import Data.Foldable
import Data.List ((:))
import Data.List as List
import Data.List.Types (List(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (unwrap)
import Data.Semigroup.Foldable (foldMap1)
import Data.String.CodePoints (contains, indexOf, indexOf', length, splitAt, take) as String
import Data.String.Common (toLower, split) as String
import Data.String.Pattern (Pattern(..)) as String
import Data.String.Regex as Regex
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (unfoldr)
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
import Prelude
import Types (Tab, TabSource, Highlight(..), favIconUrl, TabsUpdate)
import Web.Event.Event (preventDefault, stopPropagation)
import Web.HTML.Common (ClassName(..))
import Web.HTML.HTMLElement as HTMLElement
import Web.UIEvent.KeyboardEvent (KeyboardEvent(..))
import Web.UIEvent.KeyboardEvent as KeyboardEvent
import Range
import Data.Tuple.Nested (type (/\), (/\))

type State =
  { tabs :: Array Tab
  , sortedTabs :: Array Tab
  , searchQuery :: String
  , selectedIndex :: Int
  , ownWindowId :: Maybe Int
  }

data Action
  = Initialize
  | Tabs TabsUpdate
  | UpdateSearch String
  | KeyDown KeyboardEvent
  | SwitchToTab Int

component :: forall q i o m. MonadEffect m => H.Component q i o m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval { handleAction = handleAction, initialize = Just Initialize }
    }

initialState :: forall i. i -> State
initialState _ =
  { tabs: []
  , sortedTabs: []
  , searchQuery: ""
  , selectedIndex: 0
  , ownWindowId: Nothing
  }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div []
    [ HH.div
        [ HP.id "tab-view"
        , HP.tabIndex 0
        , HE.onKeyDown KeyDown
        ]
        [ HH.input
            [ HP.id "tab-search"
            , HP.type_ HP.InputText
            , HP.value state.searchQuery
            , HE.onValueInput UpdateSearch
            , HP.placeholder "Search..."
            , HP.ref (RefLabel "tabSearch")
            ]
        , HH.ol
            []
            (Array.concat (Array.mapWithIndex (renderTab state.ownWindowId state.selectedIndex state.sortedTabs) state.sortedTabs))
        , HH.div [ HP.class_ (ClassName "quick-help") ]
            [ HH.text "Use the arrow keys and ENTER to switch a tab. Ctrl+Left to close the selected tab. "
            , HH.a [ HP.href "help.html", HP.target "_blank" ] [ HH.text " Set up a hotkey." ]
            ]
        ]
    , HH.div
        [ HP.class_ (ClassName "footer") ]
        [ HH.a
            [ HP.href "#" ]
            [ HH.span [ HP.id "logo" ] []
            , HH.span [] [ HH.text "Blazing Tabs" ]
            ]
        ]
    ]

handleKeyDown :: forall o m. MonadEffect m => KeyboardEvent -> H.HalogenM State Action () o m Unit
handleKeyDown keyboardEvent = do
  case KeyboardEvent.code keyboardEvent of
    "ArrowUp" -> do
      handle
      H.modify_ (moveSelection (-1))
    "ArrowDown" -> do
      handle
      H.modify_ (moveSelection 1)
    "Enter" -> do
      handle
      getSelectedTab >>= \mbTab -> case mbTab of
        Nothing -> pure unit
        Just tab -> switchToTab tab.id
    "ArrowLeft" -> do
      when (KeyboardEvent.ctrlKey keyboardEvent) $ do
        handle
        getSelectedTab >>= \mbTab -> case mbTab of
          Nothing -> pure unit
          Just selectedTab -> do
            liftEffect $ closeTab selectedTab.id
            H.modify_ \state ->
              let
                tabs' = Array.filter (\tab -> tab.id /= selectedTab.id) state.tabs
                sortedTabs' = filterAndSort state.searchQuery tabs'
              in
                state
                  { tabs = tabs'
                  , sortedTabs = sortedTabs'
                  , selectedIndex = state.selectedIndex `mod` Array.length sortedTabs'
                  }
    "Escape" -> do
      mbFirstTab <- getFirstTab
      for_ mbFirstTab $ \tab ->
        switchToTab tab.id

    _ -> do
      pure unit
  where
  handle = liftEffect $ do
    preventDefault (KeyboardEvent.toEvent keyboardEvent)
    stopPropagation (KeyboardEvent.toEvent keyboardEvent)

  getSelectedTab = do
    state <- H.get
    pure $ Array.index state.sortedTabs state.selectedIndex

  getFirstTab = do
    state <- H.get
    pure $ Array.index state.sortedTabs 0

moveSelection :: Int -> State -> State
moveSelection delta state =
  let
    selectedIndex = (state.selectedIndex + delta) `mod` Array.length state.sortedTabs
  in
    state { selectedIndex = selectedIndex }

renderTab :: forall w. Maybe Int -> Int -> Array Tab -> Int -> Tab -> Array (HH.HTML w Action)
renderTab ownWindowId selectedIndex sortedTabs index tab =
  let
    iconBg url = "background-image: url('" <> url <> "')"
    selected = selectedIndex == index
    cls name enable = if enable then [ ClassName name ] else []
    isOtherWindow = fromMaybe false $ ((/=) tab.windowId) <$> ownWindowId
    mbTabPrev = Array.index sortedTabs (index - 1)
    windowBreak = fromMaybe true $ mbTabPrev <#> \tabPrev -> tabPrev.windowId /= tab.windowId
  in
    (if windowBreak then [ HH.li [ HP.class_ (ClassName "window-break") ] [] ] else [])
      <>
        [ HH.li
            [ HE.onClick \_ -> SwitchToTab tab.id
            , HP.classes (cls "tab" true <> cls "selected" selected <> cls "active" tab.active)
            ]
            [ HH.span [ HP.class_ (ClassName "tab-icon-wrap") ]
                [ HH.span
                    ( [ HP.class_ (ClassName "tab-icon") ] <>
                        case tab.favIconUrl of
                          Nothing -> []
                          Just favIconUrl -> [ HP.style (iconBg favIconUrl) ]
                    )
                    []
                ]
            , HH.span [ HP.class_ (ClassName "tab-title") ]
                ( ( if tab.hostname == "" then []
                    else
                      [ HH.span
                          [ HP.class_ (ClassName "hostname") ]
                          (renderHighlights tab.hostnameDisplay)
                      ]
                  )
                    <>
                      [ HH.span
                          [ HP.class_ (ClassName "title") ]
                          (renderHighlights tab.titleDisplay)
                      ]
                )
            ]
        ]

renderHighlights arr =
  map (\(Tuple hi str) -> HH.span (cls hi) [ HH.text str ]) arr
  where
  cls Highlight = [ HP.class_ (ClassName "hi") ]
  cls NoHighlight = []

hostnameRegex :: Regex.Regex
hostnameRegex = unsafeRegex "[^:]+://([^/]+)" mempty

urlHostname :: String -> String
urlHostname url =
  case Regex.match hostnameRegex url of
    Nothing -> ""
    Just groups ->
      case indexl 1 (groups) of
        Nothing -> ""
        Just Nothing -> ""
        Just (Just s) -> s

handleAction :: forall o m. MonadEffect m => Action → H.HalogenM State Action () o m Unit
handleAction = case _ of
  Initialize -> do
    { emitter, listener } <- H.liftEffect HS.create
    liftEffect $ registerCallback
      ( \tabsUpdate -> do
          HS.notify listener (Tabs tabsUpdate)
      )
    _ <- H.subscribe emitter
    pure unit

  Tabs ({ tabSources, ownWindowId }) -> do
    let
      (tabs :: Array Tab) =
        map
          ( \t ->
              { id: t.id
              , windowId: t.windowId
              , title: t.title
              , titleDisplay: [ Tuple NoHighlight t.title ]
              , favIconUrl: favIconUrl Just Nothing t
              , url: t.url
              , hostname: urlHostname t.url
              , hostnameDisplay: [ Tuple NoHighlight (urlHostname t.url) ]
              , isOwnWindowId: t.windowId == ownWindowId
              , lastActivated: t.lastActivated
              , active: t.active
              }
          )
          tabSources
    H.modify_ \st -> st { tabs = tabs, sortedTabs = filterAndSort "" tabs, searchQuery = "", ownWindowId = Just ownWindowId }

    mbEl <- H.getHTMLElementRef (RefLabel "tabSearch")
    for_ mbEl \el ->
      liftEffect $ HTMLElement.focus el
    pure unit

  UpdateSearch query -> do
    H.modify_ \st -> st
      { sortedTabs = filterAndSort query st.tabs
      , searchQuery = query
      , selectedIndex = 0
      }

  KeyDown keyboardEvent -> handleKeyDown keyboardEvent

  SwitchToTab tabId -> switchToTab tabId

switchToTab :: forall o m. MonadEffect m => Int -> H.HalogenM State Action () o m Unit
switchToTab tabId = do
  H.modify_ \st -> st
    { selectedIndex = 0
    }
  liftEffect $ ExtInterface.switchToTab tabId

data KeywordMatches
  = NoMatch
  | Matches { hostnameMatches :: Array Range, titleMatches :: Array Range }

instance keywordMachesSemigroup :: Semigroup KeywordMatches
  where
  append NoMatch _ = NoMatch
  append _ NoMatch = NoMatch
  append (Matches m1) (Matches m2) =
    Matches
      ( { hostnameMatches: m1.hostnameMatches <> m2.hostnameMatches
        , titleMatches: m1.titleMatches <> m2.titleMatches
        }
      )

mkMatch :: String -> String -> String.Pattern -> KeywordMatches
mkMatch titleLo hostnameLo q =
  let
    titleMatches = findRanges q titleLo
    hostnameMatches = findRanges q hostnameLo
  in
    if Array.all Array.null [ titleMatches, hostnameMatches ] then NoMatch
    else Matches { titleMatches, hostnameMatches }

takeRange :: Range -> String -> String
takeRange (Range l r) str =
  String.take (r - l) ((String.splitAt l str).after)

displayHightlights' :: String -> List Range -> List (Tuple Highlight String)
displayHightlights' str ranges =
  let
    n = String.length str
    f start ranges =
      case ranges of
        Nil -> (Tuple NoHighlight (takeRange (Range start n) str)) : Nil
        Range l r : rest ->
          (Tuple NoHighlight (takeRange (Range start l) str))
            : (Tuple Highlight (takeRange (Range l r) str))
            :
              f r rest
  in
    f 0 ranges

displayHightlights :: String -> Array Range -> Array (Tuple Highlight String)
displayHightlights str ranges =
  Array.fromFoldable (displayHightlights' str (List.fromFoldable ranges))

filterAndSort :: String -> Array Tab -> Array Tab
filterAndSort searchQuery tabs =
  let
    queries = Array.filter (\x -> x /= "") $ String.split (String.Pattern " ") (String.toLower searchQuery)
    tabs' = Array.sortWith (\tab -> (not tab.isOwnWindowId) /\ tab.windowId /\ (-tab.lastActivated)) $ Array.filter (\tab -> tab.title /= "Blazing Tabs") tabs
  in
    case NonEmpty.fromArray queries of
      Nothing -> tabs'
      Just qs ->
        Array.mapMaybe
          ( \tab ->
              let
                titleLo = String.toLower tab.title
                hostnameLo = String.toLower tab.hostname
              in
                case foldMap1 (mkMatch titleLo hostnameLo <<< String.Pattern) qs of
                  NoMatch -> Nothing
                  Matches m ->
                    let
                      tab' = tab
                        { titleDisplay = displayHightlights tab.title (joinRanges m.titleMatches)
                        , hostnameDisplay = displayHightlights tab.hostname (joinRanges m.hostnameMatches)
                        }
                    in
                      Just tab'
          )
          tabs'

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body
