module Main exposing (..)

import Browser

import Html exposing (Html, button, div, text, nav, span, h1, small, text, form, fieldset, input, a, i, br, p, label, h1, h2, h3, h4, img)
import Html.Events exposing (onClick, onSubmit, onInput)
import Html.Attributes as A

import List exposing (reverse)

import Array
import Array exposing (Array)
import Task
import Tuple
import Process
import Dict
import Random exposing (Generator)
import Dict exposing (Dict)
import Maybe exposing (withDefault)

import Char
import String





type alias Model
    = { bla : Integer }


type Msg
    = NoOp

initialModel : Model
initialModel
    = { bla = 3
      }

init : String -> (Model, Cmd Msg)
init flags = (initialModel, Cmd.None)

main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \model -> Sub.none }

update msg model =
    case msg of
        NoOp -> (model, Cmd.none)


updateGame : Tile -> Model -> (Model, Cmd Msg)
updateGame tile model =
    case model.gameState of
        GameOver -> (model, Cmd.none)
        AllCovert ->
            ({model|board=updateTile ({tile|state=Overt}) model.board, gameState=OneOvert tile.id}, Cmd.none)
        OneOvert tileId ->
            if tile.id == tileId
                then (model, Cmd.none)
                else ({model|board=updateTile ({tile|state=Overt}) model.board, gameState=TwoOvert tileId tile.id}, Cmd.none)
        TwoOvert t1id t2id ->
            Maybe.map2
                (\tile1 tile2 ->
                    -- if tile1.suit == tile2.suit
                    --     then
                    --         let
                    --             tile1_ = {tile1|state=Removed}
                    --             tile2_ = {tile2|state=Removed}
                    --         in
                    --             ({model|board=model.board |> updateTile tile1 |> updateTile tile2 }, Cmd.none)
                    --     else
                    --         (model, Cmd.none)
                    let
                        tile1_ = if tile1.suit == tile2.suit then {tile1|state=Removed} else {tile1|state=Covert}
                        tile2_ = if tile1.suit == tile2.suit then {tile2|state=Removed} else {tile2|state=Covert}
                    in
                        ({model | board=model.board |> updateTile tile1_ |> updateTile tile2_,
                                  gameState=AllCovert}
                        , Cmd.none))
                (Dict.get t1id model.board)
                (Dict.get t2id model.board)
            |> withDefault (model, Cmd.none)


updateTile : Tile -> Board -> Board
updateTile tile board = Dict.insert tile.id tile board

updateTileClicked model tile =
    let
        tile_ = {tile|state=(if tile.state == Covert then Overt else Covert)}
    in
        ({model|board=updateTile tile_ model.board}, Cmd.none)

emojis : Array String
emojis = Array.fromList
    [ "emoji_u1f347"
    , "emoji_u1f348"
    , "emoji_u1f349"
    , "emoji_u1f34a"
    , "emoji_u1f34b"
    , "emoji_u1f34c"
    , "emoji_u1f34d"
    , "emoji_u1f34e"
    , "emoji_u1f34f"
    , "emoji_u1f350"
    , "emoji_u1f351"
    , "emoji_u1f352"
    , "emoji_u1f353"
    , "emoji_u1f95d"
    , "emoji_u1f345"
    , "emoji_u1f965"
    , "emoji_u1f951"
    , "emoji_u1f346"
    , "emoji_u1f955"
    , "emoji_u1f33d"
    , "emoji_u1f336"
    , "emoji_u1f952"
    , "emoji_u1f966"
    , "emoji_u1f344"
    , "emoji_u1f95c"
    , "emoji_u1f35e"
    , "emoji_u1f950"
    , "emoji_u1f956"
    , "emoji_u1f968"
    , "emoji_u1f95e"
    , "emoji_u1f9c0"
    , "emoji_u1f35f"
    , "emoji_u1f355"
    , "emoji_u1f96a"
    , "emoji_u1f32e"
    , "emoji_u1f32f"
    , "emoji_u1f957"
    , "emoji_u1f367"
    , "emoji_u1f369"
    , "emoji_u1f370"
    , "emoji_u1f967"
    , "emoji_u1f36b"
    , "emoji_u1f36c"
    , "emoji_u1f36d"
    , "emoji_u1f377"
    , "emoji_u1f412"
    , "emoji_u1f98d"
    , "emoji_u1f415"
    , "emoji_u1f429"
    , "emoji_u1f98a"
    , "emoji_u1f408"
    , "emoji_u1f981"
    , "emoji_u1f405"
    , "emoji_u1f40e"
    , "emoji_u1f984"
    , "emoji_u1f993"
    , "emoji_u1f98c"
    , "emoji_u1f402"
    , "emoji_u1f404"
    , "emoji_u1f416"
    , "emoji_u1f417"
    , "emoji_u1f40f"
    , "emoji_u1f42a"
    , "emoji_u1f992"
    , "emoji_u1f418"
    , "emoji_u1f98f"
    , "emoji_u1f401"
    , "emoji_u1f439"
    , "emoji_u1f407"
    , "emoji_u1f43f"
    , "emoji_u1f994"
    , "emoji_u1f987"
    , "emoji_u1f43b"
    , "emoji_u1f428"
    , "emoji_u1f43c"
    , "emoji_u1f414"
    , "emoji_u1f413"
    , "emoji_u1f424"
    , "emoji_u1f426"
    , "emoji_u1f427"
    , "emoji_u1f54a"
    , "emoji_u1f986"
    , "emoji_u1f989"
    , "emoji_u1f40a"
    , "emoji_u1f422"
    , "emoji_u1f98e"
    , "emoji_u1f40d"
    , "emoji_u1f995"
    , "emoji_u1f433"
    , "emoji_u1f42c"
    , "emoji_u1f41f"
    , "emoji_u1f420"
    , "emoji_u1f421"
    , "emoji_u1f988"
    , "emoji_u1f419"
    , "emoji_u1f41a"
    , "emoji_u1f980"
    , "emoji_u1f990"
    , "emoji_u1f991"
    , "emoji_u1f40c"
    , "emoji_u1f98b"
    , "emoji_u1f41b"
    , "emoji_u1f41c"
    , "emoji_u1f41d"
    , "emoji_u1f41e"
    , "emoji_u1f997"
    , "emoji_u1f577"
    , "emoji_u1f339"
    , "emoji_u1f33b"
    , "emoji_u1f33c"
    , "emoji_u1f337"
    , "emoji_u1f332"
    , "emoji_u1f333"
    , "emoji_u1f334"
    , "emoji_u1f335"
    , "emoji_u1f340"
    , "emoji_u1f341" ]

getEmoji : Int -> String
getEmoji k =
    Array.get k emojis |> Maybe.withDefault ""

emoji : Int -> Html Msg
emoji k = div [ A.class "emoji" ] []

card : Int -> Html Msg
card k =
    div [ A.class "square" ]
        [ div [ A.class ("content card " ++ getEmoji k) ] [] ] 

backside : Html Msg
backside = div [ A.class "square" ] [ div [ A.class "content backside" ] [] ]

linebreak = div [ A.class "linebreak" ] []

viewTile tile =
    case tile.state of
        Overt ->
            div [ A.class "square", onClick (TileClicked tile.id) ]
                [ div [ A.class ("content card " ++ tile.suit)] [] ] 
        Covert ->
            div [ A.class "square", onClick (TileClicked tile.id) ]
                [ div [ A.class "content backside"] [] ] 
        Removed ->
            div [ A.class "square removed", onClick (TileClicked tile.id) ]
                [ div [ A.class "content" ] [] ] 

maybe : b -> (a -> b) -> Maybe a -> b
maybe def f m =
    withDefault def (Maybe.map f m)

emptyDiv : Html Msg
emptyDiv = div [] []

view model =
    div [ A.class "square-container" ]
    (List.map (\k -> (Dict.get k model.board) |> maybe emptyDiv viewTile) (List.range 0 35))

enumerate : List a -> List (Int, a)
enumerate l =
    let nums = List.range 0 (List.length l - 1)
    in List.map2 (\idx x -> (idx, x)) nums l

mkTile : Int -> Suit -> TileId -> Tile
mkTile n suit idx =
    let matchingTile =
            if idx < n // 2
                then idx + n // 2
                else idx - n // 2
    in
        Tile idx Covert [] matchingTile suit

randomNewBoardGen : Int -> Generator Board
randomNewBoardGen n =
    let
        l = List.range 0 ((n // 2) - 1)
        matchesGen = Random.List.shuffle (enumerate (l ++ l))
        suitsGen = Random.Array.shuffle emojis
        f matches suits =
            let
                tiles = List.map (\(idx, matchIdx) -> mkTile n (withDefault "" (Array.get matchIdx suits)) idx) matches
            in
                Dict.fromList (List.map (\tile -> (tile.id, tile)) tiles )
    in
        Random.map2 f matchesGen suitsGen


        


