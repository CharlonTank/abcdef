module Types exposing (BackendModel, BackendMsg(..), Direction(..), FrontendModel, FrontendMsg(..), RobotMovement(..), RobotState, TileColor(..), ToBackend(..), ToFrontend(..))

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Url exposing (Url)


type alias BackendModel =
    { robotState : RobotState
    , clients : Set ClientId
    }


type alias FrontendModel =
    { key : Key
    , robotState : RobotState
    }


type alias RobotState =
    { position : ( Int, Int )
    , direction : Direction
    , angle : Float
    , tileColors : Dict ( Int, Int ) TileColor
    , clientCount : Int
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | SendMoveRobot RobotMovement
    | ResetClicked


type ToBackend
    = MoveRobot RobotMovement
    | ResetRobot


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected SessionId ClientId
    | ClientDisconnected SessionId ClientId


type ToFrontend
    = SyncRobotState RobotState


type Direction
    = North
    | East
    | South
    | West


type TileColor
    = Color1
    | Color2
    | Color3
    | Color4


type RobotMovement
    = MoveForward
    | RotateLeft
    | RotateRight
