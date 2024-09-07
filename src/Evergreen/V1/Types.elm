module Evergreen.V1.Types exposing (BackendModel, BackendMsg(..), Direction(..), FrontendModel, FrontendMsg(..), RobotMovement(..), RobotState, TileColor(..), ToBackend(..), ToFrontend(..))

import Browser
import Browser.Navigation
import Dict
import Lamdera
import Set


type Direction
    = West


type TileColor
    = Color4


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
    = RotateRight


type FrontendMsg
    = UrlClicked Browser.UrlRequest


type ToBackend
    = ResetRobot


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = SyncRobotState RobotState
