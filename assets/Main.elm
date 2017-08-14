module Main exposing (main)

import Animation
import Data
import Dict
import Fixtures
import GraphQL.Client.Http as Gr
import Html
import Task
import Model exposing (Model, Msg(..))
import Update exposing (update)
import View exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
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


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        cohortHovers =
            Dict.values model.cohortHover
                |> List.foldl (\( a, b ) acc -> acc ++ [ a, b ]) []
    in
        Animation.subscription Animate cohortHovers
