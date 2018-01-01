module Main exposing (main)

import Animation
import Api
import Dict
import Fixtures
import Html
import Model exposing (Model, Msg(..))
import Task
import Update exposing (update)
import View exposing (view)
import Window


main : Program ( String, String ) Model Msg
main =
    Html.programWithFlags
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : ( String, String ) -> ( Model, Cmd Msg )
init ( url, githubToken ) =
    let
        model =
            Fixtures.emptyModel
    in
    { model | githubToken = githubToken }
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
