module Frontend exposing (..)

import Browser exposing (Document)
import Browser.Events exposing (onKeyDown)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Lamdera
import Svg exposing (Svg, g, image, svg)
import Svg.Attributes as SvgAttr
import Types exposing (..)
import Url


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


init : Url.Url -> Nav.Key -> ( FrontendModel, Cmd FrontendMsg )
init _ key =
    ( { key = key
      , robotState =
            { position = ( 2, 2 )
            , direction = North
            , angle = 0
            , tileColors = Dict.empty
            , clientCount = 0
            }
      }
    , Cmd.none
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        SendMoveRobot movement ->
            ( model, Lamdera.sendToBackend (MoveRobot movement) )

        ResetClicked ->
            ( model, Lamdera.sendToBackend ResetRobot )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        SyncRobotState newState ->
            ( { model | robotState = newState }, Cmd.none )


subscriptions : FrontendModel -> Sub FrontendMsg
subscriptions _ =
    onKeyDown keyDecoder


keyDecoder : Decode.Decoder FrontendMsg
keyDecoder =
    Decode.map toDirection (Decode.field "key" Decode.string)


toDirection : String -> FrontendMsg
toDirection string =
    case string of
        "ArrowUp" ->
            SendMoveRobot MoveForward

        "ArrowLeft" ->
            SendMoveRobot RotateLeft

        "ArrowRight" ->
            SendMoveRobot RotateRight

        _ ->
            NoOpFrontendMsg


view : FrontendModel -> Document FrontendMsg
view model =
    { title = "Robot Simulation"
    , body =
        [ div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "align-items" "center"
            , style "justify-content" "center"
            , style "height" "100vh"
            , style "width" "100vw"
            ]
            [ svg
                [ SvgAttr.width "500"
                , SvgAttr.height "500"
                , SvgAttr.viewBox "0 0 500 500"
                ]
                [ g [ SvgAttr.transform "translate(0, 0)" ]
                    (viewGrid model.robotState.tileColors ++ [ viewRobot model.robotState ])
                ]
            , viewClientCount model.robotState.clientCount
            , button
                [ onClick ResetClicked
                , style "margin-top" "20px"
                , style "padding" "10px 20px"
                , style "font-size" "16px"
                ]
                [ text "Reset Robot" ]
            ]
        ]
    }


viewClientCount : Int -> Html FrontendMsg
viewClientCount count =
    p
        [ style "margin" "20px 0"
        , style "font-size" "18px"
        , style "font-weight" "bold"
        ]
        [ text ("Connected Clients: " ++ String.fromInt count) ]


viewGrid : Dict ( Int, Int ) TileColor -> List (Svg FrontendMsg)
viewGrid tileColors =
    List.concat
        [ List.concatMap (\x -> List.map (\y -> viewTile ( x, y ) (Dict.get ( x, y ) tileColors)) (List.range 0 4)) (List.range 0 4)
        , List.map (\i -> viewGridLine ( i * 100, 0 ) ( i * 100, 500 )) (List.range 0 5)
        , List.map (\i -> viewGridLine ( 0, i * 100 ) ( 500, i * 100 )) (List.range 0 5)
        ]


viewTile : ( Int, Int ) -> Maybe TileColor -> Svg FrontendMsg
viewTile ( x, y ) maybeTileColor =
    Svg.rect
        [ SvgAttr.x (String.fromInt (x * 100))
        , SvgAttr.y (String.fromInt (y * 100))
        , SvgAttr.width "100"
        , SvgAttr.height "100"
        , SvgAttr.fill (tileColorToHex (Maybe.withDefault Color1 maybeTileColor))
        ]
        []


viewGridLine : ( Int, Int ) -> ( Int, Int ) -> Svg FrontendMsg
viewGridLine ( x1, y1 ) ( x2, y2 ) =
    Svg.line
        [ SvgAttr.x1 (String.fromInt x1)
        , SvgAttr.y1 (String.fromInt y1)
        , SvgAttr.x2 (String.fromInt x2)
        , SvgAttr.y2 (String.fromInt y2)
        , SvgAttr.stroke "black"
        , SvgAttr.strokeWidth "2"
        ]
        []


viewRobot : RobotState -> Svg FrontendMsg
viewRobot state =
    let
        ( x, y ) =
            state.position

        centerX =
            x * 100 + 50

        centerY =
            y * 100 + 50
    in
    Svg.g
        [ SvgAttr.transform ("translate(" ++ String.fromInt centerX ++ "," ++ String.fromInt centerY ++ ") rotate(" ++ String.fromFloat state.angle ++ ")")
        , SvgAttr.style "transition: transform 0.3s ease-in-out;"
        ]
        [ image
            [ SvgAttr.xlinkHref "/robot-owl.svg"
            , SvgAttr.width "60"
            , SvgAttr.height "60"
            , SvgAttr.x "-30"
            , SvgAttr.y "-30"
            ]
            []
        ]


tileColorToHex : TileColor -> String
tileColorToHex color =
    case color of
        Color1 ->
            "#F7F7F7"

        Color2 ->
            "#4780BB"

        Color3 ->
            "#E15A1D"

        Color4 ->
            "#9CB9BF"
