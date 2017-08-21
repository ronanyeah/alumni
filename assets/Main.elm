module Main exposing (main)

import Animation
import Data
import Dict
import Fixtures
import Html
import Task
import Model exposing (Model, Msg(Animate, CbCampuses))
import Update exposing (update)
import View exposing (view)


main : Program ( String, String, String ) Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : ( String, String, String ) -> ( Model, Cmd Msg )
init ( url, githubId, githubSecret ) =
    let
        model =
            Fixtures.emptyModel
    in
        { model | githubAuth = ( githubId, githubSecret ) }
            ! [ Task.attempt CbCampuses (Data.fetch url)
              ]


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        cohortHovers =
            Dict.values model.cohortAnims
                |> List.foldl (\( a, b ) acc -> acc ++ [ a, b ]) []
    in
        Animation.subscription Animate cohortHovers
