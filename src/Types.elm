module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Url exposing (Url)


type alias FrontendModel =
    { key : Key
    , robotPosition : ( Int, Int )
    , robotDirection : Direction
    , robotAngle : Float
    , tileColors : Dict ( Int, Int ) TileColor
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | MoveForward
    | RotateLeft
    | RotateRight


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend


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
