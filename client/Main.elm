module Main exposing (main)

import Animation
import Api
import Dict
import Fixtures
import Html
import Task
import Model exposing (Model, Msg(..))
import Update exposing (update)
import View exposing (view)
import Window


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
            ! [ Task.attempt CbCampuses (Api.fetchCampuses url)
              , Task.perform Resize Window.size
              ]


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        cohortAnimations =
            Dict.values model.cohortAnims
                |> List.foldl (\( a, b ) acc -> acc ++ [ a, b ]) []
    in
        Sub.batch
            [ Animation.subscription Animate cohortAnimations
            , Window.resizes Resize
            ]
