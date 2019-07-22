port module Main exposing (..)

import Browser

import Html exposing (Html, button, div, text, nav, span, h1, small, text, form, fieldset, input, a, i, br, p, label, h1, h2, h3, h4, img, ol, li)
import Html.Events exposing (onClick, onSubmit, onInput, stopPropagationOn, keyCode, on, custom)
import Html.Attributes as A

import List exposing (reverse)

import Array
import Array exposing (Array)
import Task
import Tuple
import Process
import Dict
import Dict exposing (Dict)
import Maybe exposing (withDefault)

import Char
import String
import Debug

import Json.Encode as E
import Json.Decode as D


type alias Model =
  { bla : Int
  , tabs : List Tab
  , selectedIndex : Int
  , sortedTabs : List Tab
  , searchQuery : String
  }


type alias Tab
  = { id : Int
    , windowId : Int
    , index : Int
    , title : String
    , favIconUrl : Maybe String
    , lastAccessed : Int
    , url : String
    }

type Msg
    = NoOp
    | HighlightTab Tab
    | CloseTab Tab
    | Tabs (List Tab)
    | Refresh
    | SelectionDown
    | SelectionUp
    | UpdateSearch String

initialModel : Model
initialModel
    = { bla = 3
      , tabs = []
      , selectedIndex = 0
      , sortedTabs = []
      , searchQuery = ""
      }

init : String -> (Model, Cmd Msg)
init flags = (initialModel, queryTabs E.null)

main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions }

maybe : b -> (a -> b) -> Maybe a -> b
maybe def f m =
  Maybe.withDefault def (Maybe.map f m)


keepBounds : Int -> Int -> Int
keepBounds n i =
  min (max 0 i) (n - 1)


computeSorted : Model -> Model
computeSorted model =
  let
    tabs_ = (List.filter (\tab -> tab.title /= "Stabber") (model.tabs))
    sortedTabs =
      if (model.searchQuery == "")
        then
          List.sortBy
            (\tab -> -tab.lastAccessed)
            (List.filter (\tab -> tab.title /= "Stabber") tabs_)
        else
          let q = String.toLower model.searchQuery
              tabsFiltered =
                List.filter
                (\tab ->
                  let
                    title = String.toLower tab.title
                    url = String.toLower tab.url
                  in
                    String.contains q title || String.contains q url)
                tabs_
          in
              List.sortBy
              (\tab ->
                let
                    title = String.toLower tab.title
                    url = String.toLower tab.url
                    idxs = String.indices q title ++ String.indices q url
                in
                    Maybe.withDefault 10000 (List.minimum idxs)
              )
              tabsFiltered

  in
    { model
    | sortedTabs = sortedTabs
    , selectedIndex = keepBounds (List.length sortedTabs) model.selectedIndex
    }

clipIndex : Int -> Int -> Int
clipIndex n i = max (min i (n - 1)) 0

update msg model =
    case msg of
        NoOp -> (model, Cmd.none)
        Tabs tabs_ -> (computeSorted ({model | tabs = tabs_, selectedIndex = 0, searchQuery=""}), Cmd.none)
        HighlightTab tab -> (computeSorted {model|searchQuery="", selectedIndex=0}, highlightTab tab)
        Refresh -> (model, queryTabs E.null)
        CloseTab tab -> (computeSorted {model | tabs = List.filter (\t -> t.id /= tab.id) model.tabs }, closeTab tab.id)
        SelectionDown ->
          ( 
            let
                n = List.length model.sortedTabs
                i = model.selectedIndex
                iNext = if i == n - 1 then 0 else i + 1
            in {model|selectedIndex = clipIndex n iNext}
          , Cmd.none)
        SelectionUp ->
          ( 
            let
               n = List.length model.sortedTabs
               i = model.selectedIndex
               iNext = if i == 0 then n - 1 else i - 1
            in {model|selectedIndex = clipIndex n iNext}
          , Cmd.none)
        UpdateSearch s ->
          (computeSorted {model|searchQuery=s}, Cmd.none)


handleKey : Model -> Int -> { message : Msg, stopPropagation : Bool, preventDefault : Bool }
handleKey model k = 
  case k of
    38 -> {message = SelectionUp, stopPropagation = True, preventDefault = True}
    40 -> {message = SelectionDown, stopPropagation = True, preventDefault = True}
    13 -> { message = 
              case List.head (List.drop (model.selectedIndex) model.sortedTabs) of
                Nothing -> NoOp
                Just tab -> HighlightTab tab
          , stopPropagation = True
          , preventDefault = True}
    _ -> {message = NoOp, stopPropagation = False, preventDefault = False}


viewTab : Model -> (Int, Tab) -> Html Msg
viewTab model (index, tab) =
  let
    iconBg = "url('" ++ Maybe.withDefault "" tab.favIconUrl ++ "')"
    selected = model.selectedIndex == index
  in
    li
    [ A.classList [("tab", True), ("selected", selected)], onClick (HighlightTab tab) ]
    [ span [ A.class "tab-close-button", stopPropagationOn "click" (D.succeed (CloseTab tab, True)) ] [ i [ A.class "fas fa-times-circle"] [] ]
    , span [ A.class "tab-icon-wrap" ] [ span [ A.class "tab-icon", A.style "background-image" iconBg ] [] ]
    , span [ A.class "tab-title tab-link" ]
           [ span [] [ text tab.title ]
           -- , span [ A.class "tab-url" ] [ text tab.title ]
           ]
    ]

view model =
  div
    [ A.id "tab-view"
    , A.tabindex 0
    , custom "keydown" (D.map (handleKey model) keyCode)
    ]
    [ input
        [ A.id "tab-search"
        , A.type_ "text"
        , onInput UpdateSearch
        , A.value (model.searchQuery)
        , A.placeholder "Type to SErch..."
        ]
        []

      -- button [ onClick Refresh ] [ text "refresh"]
    , ol [] (
        (List.indexedMap Tuple.pair model.sortedTabs) |> List.map (viewTab model)
      )
    ]


port tabs : (E.Value -> msg) -> Sub msg


subscriptions model =
  tabs parseTabs


decoder : D.Decoder (List Tab)
decoder =
  let
      tabDecoder =
        D.map7
          Tab
          (D.field "id" D.int)
          (D.field "windowId" D.int)
          (D.field "index" D.int)
          (D.field "title" D.string)
          (D.field "favIconUrl" (D.nullable (D.string)))
          (D.field "lastAccessed" (D.int))
          (D.field "url" (D.string))
  in
    D.list tabDecoder

parseTabs : E.Value -> Msg
parseTabs val =
  case D.decodeValue decoder val of
    Err msg -> Debug.log (Debug.toString msg) NoOp
    Ok tabs_ -> Tabs tabs_


highlightTabs : Int -> List Int -> Cmd msg
highlightTabs windowId indices = 
  let highlightInfo =
        E.object [("windowId", E.int windowId), ("tabs", (E.list E.int indices) )]
  in highlight highlightInfo

port highlight : E.Value -> Cmd msg


highlightTab : Tab -> Cmd msg
highlightTab tab = highlightTabs tab.windowId [tab.index]

port queryTabs : E.Value -> Cmd msg

closeTab : Int -> Cmd msg
closeTab tabId = doCloseTab (E.object [("tabId", E.int tabId)])

port doCloseTab : E.Value -> Cmd msg
