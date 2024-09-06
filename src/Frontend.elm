module Frontend exposing (..)

import Browser exposing (Document)
import Browser.Events exposing (onKeyDown)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (div)
import Json.Decode as Decode
import Lamdera
import Svg exposing (Svg, image, svg)
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
      , robotPosition = ( 2, 2 )
      , robotDirection = North
      , robotAngle = 0
      , tileColors = initColors
      }
    , Cmd.none
    )


initColors : Dict ( Int, Int ) TileColor
initColors =
    Dict.fromList
        [ ( ( 0, 0 ), Color1 )
        , ( ( 1, 0 ), Color2 )
        , ( ( 2, 0 ), Color3 )
        , ( ( 3, 0 ), Color4 )
        , ( ( 4, 0 ), Color1 )
        , ( ( 0, 1 ), Color2 )
        , ( ( 1, 1 ), Color3 )
        , ( ( 2, 1 ), Color4 )
        , ( ( 3, 1 ), Color1 )
        , ( ( 4, 1 ), Color2 )
        , ( ( 0, 2 ), Color3 )
        , ( ( 1, 2 ), Color4 )
        , ( ( 2, 2 ), Color1 )
        , ( ( 3, 2 ), Color2 )
        , ( ( 4, 2 ), Color3 )
        , ( ( 0, 3 ), Color4 )
        , ( ( 1, 3 ), Color1 )
        , ( ( 2, 3 ), Color2 )
        , ( ( 3, 3 ), Color3 )
        , ( ( 4, 3 ), Color4 )
        , ( ( 0, 4 ), Color1 )
        , ( ( 1, 4 ), Color2 )
        , ( ( 2, 4 ), Color3 )
        , ( ( 3, 4 ), Color4 )
        , ( ( 4, 4 ), Color1 )
        ]


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked _ ->
            ( model, Cmd.none )

        UrlChanged _ ->
            ( model, Cmd.none )

        MoveForward ->
            let
                newPosition =
                    moveForward model.robotPosition model.robotDirection

                newTileColors =
                    if newPosition /= model.robotPosition then
                        Dict.update newPosition
                            (Maybe.map nextTileColor >> Maybe.withDefault Color1 >> Just)
                            model.tileColors

                    else
                        model.tileColors
            in
            ( { model
                | robotPosition = newPosition
                , tileColors = newTileColors
              }
            , Cmd.none
            )

        RotateLeft ->
            ( { model
                | robotDirection = rotateLeft model.robotDirection
                , robotAngle = model.robotAngle - 90
              }
            , Cmd.none
            )

        RotateRight ->
            ( { model
                | robotDirection = rotateRight model.robotDirection
                , robotAngle = model.robotAngle + 90
              }
            , Cmd.none
            )

        NoOpFrontendMsg ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


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
            MoveForward

        "ArrowLeft" ->
            RotateLeft

        "ArrowRight" ->
            RotateRight

        _ ->
            NoOpFrontendMsg


view : FrontendModel -> Document FrontendMsg
view model =
    { title = "Robot Simulation"
    , body =
        [ div []
            [ svg
                [ SvgAttr.width "500"
                , SvgAttr.height "500"
                , SvgAttr.viewBox "0 0 500 500"
                ]
                (viewGrid model.tileColors ++ [ viewRobot model ])
            ]
        ]
    }


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


viewRobot : FrontendModel -> Svg FrontendMsg
viewRobot model =
    let
        ( x, y ) =
            model.robotPosition

        centerX =
            x * 100 + 50

        centerY =
            y * 100 + 50
    in
    Svg.g
        [ SvgAttr.transform ("translate(" ++ String.fromInt centerX ++ "," ++ String.fromInt centerY ++ ") rotate(" ++ String.fromFloat model.robotAngle ++ ")")
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


moveForward : ( Int, Int ) -> Direction -> ( Int, Int )
moveForward ( x, y ) direction =
    case direction of
        North ->
            ( x, max 0 (y - 1) )

        East ->
            ( min 4 (x + 1), y )

        South ->
            ( x, min 4 (y + 1) )

        West ->
            ( max 0 (x - 1), y )


rotateLeft : Direction -> Direction
rotateLeft direction =
    case direction of
        North ->
            West

        West ->
            South

        South ->
            East

        East ->
            North


rotateRight : Direction -> Direction
rotateRight direction =
    case direction of
        North ->
            East

        East ->
            South

        South ->
            West

        West ->
            North


positionToString : ( Int, Int ) -> String
positionToString ( x, y ) =
    "(" ++ String.fromInt x ++ ", " ++ String.fromInt y ++ ")"


directionToString : Direction -> String
directionToString direction =
    case direction of
        North ->
            "North"

        East ->
            "East"

        South ->
            "South"

        West ->
            "West"


nextTileColor : TileColor -> TileColor
nextTileColor color =
    case color of
        Color1 ->
            Color2

        Color2 ->
            Color3

        Color3 ->
            Color4

        Color4 ->
            Color1


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
