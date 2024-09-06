module Backend exposing (..)

import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Types exposing (..)


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { robotState = initialRobotState
      , clients = Set.empty
      }
    , Cmd.none
    )


initialRobotState : RobotState
initialRobotState =
    { position = ( 2, 2 )
    , direction = North
    , angle = 0
    , tileColors = initColors
    , clientCount = 0 -- Initialize client count
    }


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg ({ robotState } as model) =
    case msg of
        ClientConnected sessionId clientId ->
            let
                newClients =
                    Set.insert clientId model.clients

                newRobotState =
                    { robotState | clientCount = Set.size newClients }
            in
            ( { model
                | clients = newClients
                , robotState = newRobotState
              }
            , broadcastRobotState newRobotState newClients
            )

        ClientDisconnected sessionId clientId ->
            let
                newClients =
                    Set.remove clientId model.clients

                newRobotState =
                    { robotState | clientCount = Set.size newClients }
            in
            ( { model
                | clients = newClients
                , robotState = newRobotState
              }
            , broadcastRobotState newRobotState newClients
            )

        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        MoveRobot movement ->
            let
                newRobotState =
                    updateRobotState movement model.robotState
            in
            ( { model | robotState = newRobotState }
            , broadcastRobotState newRobotState model.clients
            )

        ResetRobot ->
            let
                newRobotState =
                    { initialRobotState | clientCount = model.robotState.clientCount }
            in
            ( { model | robotState = newRobotState }
            , broadcastRobotState newRobotState model.clients
            )


updateRobotState : RobotMovement -> RobotState -> RobotState
updateRobotState movement state =
    case movement of
        MoveForward ->
            let
                newPosition =
                    moveForward state.position state.direction

                newTileColors =
                    if newPosition /= state.position then
                        Dict.update newPosition
                            (Maybe.map nextTileColor >> Maybe.withDefault Color1 >> Just)
                            state.tileColors

                    else
                        state.tileColors
            in
            { state | position = newPosition, tileColors = newTileColors }

        RotateLeft ->
            { state
                | direction = rotateLeft state.direction
                , angle = state.angle - 90
            }

        RotateRight ->
            { state
                | direction = rotateRight state.direction
                , angle = state.angle + 90
            }


broadcastRobotState : RobotState -> Set ClientId -> Cmd BackendMsg
broadcastRobotState state clients =
    Set.toList clients
        |> List.map (\clientId -> Lamdera.sendToFrontend clientId (SyncRobotState state))
        |> Cmd.batch


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Lamdera.onDisconnect ClientDisconnected
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
