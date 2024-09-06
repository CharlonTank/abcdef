module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Lamdera
import Set
import Url


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


type alias RobotState =
    { position : ( Int, Int )
    , direction : Direction
    , angle : Float
    , tileColors : Dict.Dict ( Int, Int ) TileColor
    , clientCount : Int
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , robotState : RobotState
    }


type alias BackendModel =
    { robotState : RobotState
    , clients : Set.Set Lamdera.ClientId
    }


type RobotMovement
    = MoveForward
    | RotateLeft
    | RotateRight


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | SendMoveRobot RobotMovement
    | ResetClicked


type ToBackend
    = MoveRobot RobotMovement
    | ResetRobot


type BackendMsg
    = NoOpBackendMsg
    | ClientConnected Lamdera.SessionId Lamdera.ClientId
    | ClientDisconnected Lamdera.SessionId Lamdera.ClientId


type ToFrontend
    = SyncRobotState RobotState
