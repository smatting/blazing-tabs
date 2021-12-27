module Main where

import Prelude
import Callback (registerCallback)
import Data.Array as Array
import Data.Array.NonEmpty as NonEmpty
import Data.Foldable
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Pattern (Pattern(..)) as String
import Data.String.CodePoints (contains, indexOf, indexOf', length, splitAt, take) as String
import Data.String.Common (toLower, split) as String
import Data.String.Regex as Regex
import Data.Tuple (Tuple(..))
import Data.List.Types (List(..))
import Data.List as List
import Data.List ((:))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console as Console
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Data.Newtype (unwrap)
import Data.Unfoldable (unfoldr)
import Data.Semigroup.Foldable (foldMap1)
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Query.Input (RefLabel(..))
import Halogen.Subscription as HS
import Halogen.VDom.Driver (runUI)
import Types (Tab, TabSource, Highlight(..))
import Web.HTML.Common (ClassName(..))
import Web.HTML.HTMLElement as HTMLElement
import DOM.HTML.Indexed
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Array.NonEmpty (head) as NonEmpty

type State = { enabled :: Boolean,
               tabs :: Array Tab,
               sortedTabs :: Array Tab,
               searchQuery :: String,
               selectedIndex :: Int
             }

data Action = Toggle
            | Initialize
            | Tabs (Array TabSource)
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
          HP.placeholder "type to search...",
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
    [
      -- HH.span [ HP.class_ (ClassName "tab-close-button"), HE.onClick \_ -> CloseTab tab]
      --         [ HH.span [] [HH.text "close"]],

      HH.span [ HP.class_ (ClassName "tab-icon-wrap") ]
              [
                HH.span
                  [ HP.class_ (ClassName "tab-icon"),
                    HP.style iconBg
                  ]
                  []
              ],
      HH.span [ HP.class_ (ClassName "tab-title") ]
              (
                (if tab.hostname == "" then [] else [HH.span [ HP.class_ (ClassName "hostname") ] (renderHighlights tab.hostnameDisplay)])
                <> [HH.span [ HP.class_ (ClassName "title") ] (renderHighlights tab.titleDisplay)]
              )
      -- HH.div [ HP.class_ (ClassName "tab-hostname") ]
    ]

renderHighlights arr =
  map (\(Tuple hi str) -> HH.span (cls hi) [HH.text str]) arr
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
      case indexl 1 ( groups ) of
        Nothing -> ""
        Just Nothing -> ""
        Just (Just s) -> s

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

  Tabs tabsources -> do
    -- H.liftEffect $ Console.log ("tabs " <> show tabs)
    let (tabs :: Array Tab) =
          map (\t ->
                { id: t.id,
                  windowId: t.windowId,
                  index: t.index,
                  title: t.title,
                  titleDisplay: [Tuple NoHighlight t.title],
                  favIconUrl: t.favIconUrl,
                  url: t.url,
                  hostname: urlHostname t.url,
                  hostnameDisplay: [Tuple NoHighlight (urlHostname t.url)] })
              tabsources
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
    pure unit

  NoOp -> do
    pure unit

-- range in a string, indexes are 0-based
-- second index is exlcusive
data Range = Range Int Int

derive instance eqRange :: Eq Range

instance rangeShow :: Show Range
  where
    show (Range a b) = "Range " <> show a <> " " <> show b

findRanges :: String.Pattern -> String -> Array Range
findRanges pat s =
  let k = String.length (unwrap pat)
  in
   if k == 0
      then []
      else
        unfoldr
            (\pos ->
                case String.indexOf' pat pos s of
                  Nothing -> Nothing
                  Just i -> Just (Tuple (Range i (i + k)) (i + k))
            ) 0

mergeRange :: Range -> Range -> Maybe Range
mergeRange range1@(Range l1 r1) range2@(Range l2 r2)
  | l1 > l2 = mergeRange range2 range1
  | l2 <= r1 = Just (Range l1 (max r1 r2))
  | otherwise = Nothing

joinSortedRanges :: List Range -> List Range
joinSortedRanges Nil = Nil
joinSortedRanges (Cons r1 rs) =
  case rs of
    Nil -> r1 : Nil
    r2 : rest ->
      case mergeRange r1 r2 of
        Nothing -> r1 : joinSortedRanges (r2 : rest)
        Just rMerged -> joinSortedRanges (rMerged : rest)

joinRanges :: Array Range -> Array Range
joinRanges =
  Array.sortWith f >>> List.fromFoldable >>> joinSortedRanges >>> Array.fromFoldable
  where
    f :: Range -> Int
    f (Range l r) = l


data KeywordMatches
      = NoMatch
      | Matches { hostnameMatches :: Array Range, titleMatches :: Array Range }

instance keywordMachesSemigroup :: Semigroup KeywordMatches
  where
    append NoMatch _ = NoMatch
    append _ NoMatch = NoMatch
    append (Matches m1) (Matches m2) = Matches ({ hostnameMatches: m1.hostnameMatches <> m2.hostnameMatches,
                                                  titleMatches: m1.titleMatches <> m2.titleMatches })

mkMatch :: String -> String -> String.Pattern -> KeywordMatches
mkMatch titleLo hostnameLo q =
  let
      titleMatches = findRanges q titleLo
      hostnameMatches = findRanges q hostnameLo
  in
     if Array.all Array.null [titleMatches, hostnameMatches]
        then NoMatch
        else Matches { titleMatches, hostnameMatches }

takeRange :: Range -> String -> String
takeRange (Range l r) str =
  String.take (r - l) ((String.splitAt l str).after)

displayHightlights' :: String -> List Range -> List (Tuple Highlight String)
displayHightlights' str ranges =
  let n = String.length str
      f start ranges =
          case ranges of
            Nil -> (Tuple NoHighlight (takeRange (Range start n) str)) : Nil
            Range l r : rest ->
              (Tuple NoHighlight (takeRange (Range start l) str)) :
                (Tuple Highlight (takeRange (Range l r) str)) :
                  f r rest
  in f 0 ranges

displayHightlights :: String -> Array Range -> Array (Tuple Highlight String)
displayHightlights str ranges =
  Array.fromFoldable (displayHightlights' str (List.fromFoldable ranges))

filterAndSort ::  String -> Array Tab -> Array Tab
filterAndSort searchQuery tabs =
  let xs = Array.filter (\x -> x /= "") $ String.split (String.Pattern " ") (String.toLower searchQuery)
      tabs' = Array.filter (\tab -> tab.title /= "Stabber") tabs
  in
    case NonEmpty.fromArray xs of
      Nothing -> tabs'
      Just qs -> Array.mapMaybe
                    (\tab ->
                        let titleLo = String.toLower tab.title
                            hostnameLo = String.toLower tab.hostname
                        in
                          case foldMap1 (mkMatch titleLo hostnameLo <<< String.Pattern) qs of
                            NoMatch -> Nothing
                            Matches m ->
                              let tab' = tab {titleDisplay = displayHightlights tab.title (joinRanges m.titleMatches),
                                              hostnameDisplay = displayHightlights tab.hostname (joinRanges m.hostnameMatches)}
                              in Just tab')
                    tabs'

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI component unit body
