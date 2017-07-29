module Main exposing (main)

import Data
import Fixtures
import GraphQL.Client.Http as Gr
import Html
import Task
import Types exposing (Model)
import Update exposing (Msg(..), update)
import View exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


init : ( Model, Cmd Msg )
init =
    Fixtures.emptyModel
        ! [ Data.queryAllData
                |> Gr.sendQuery "/graph?query="
                |> Task.attempt CbAllData
          ]
