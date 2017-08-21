module Update exposing (update)

import Animation exposing (deg)
import Dict
import Fixtures exposing (frontInit, backInit)
import Json.Decode as Decode
import Helpers exposing (log)
import Http
import Model exposing (Model, Msg(..), GithubImage(..))
import Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate animMsg ->
            { model
                | cohortAnims =
                    model.cohortAnims
                        |> Dict.map
                            (\_ ( front, back ) ->
                                ( Animation.update animMsg front, Animation.update animMsg back )
                            )
            }
                ! []

        CbCampuses res ->
            case res of
                Ok { allCampuses } ->
                    { model
                        | campuses = allCampuses
                    }
                        ! []

                Err err ->
                    model ! [ log "err" err ]

        CbGithubImage username res ->
            case res of
                Ok img ->
                    { model | githubImages = Dict.insert username (GithubImage img) model.githubImages } ! []

                Err err ->
                    { model | githubImages = Dict.insert username Failed model.githubImages }
                        ! [ log "github err" err ]

        SelectCampus campusId ->
            let
                selectedCampus =
                    if campusId == model.selectedCampus then
                        ""
                    else
                        campusId
            in
                { model | selectedCampus = selectedCampus, selectedCohort = "", cohortAnims = Dict.empty } ! []

        SelectCohort id ->
            let
                ( selectedCohort, frontAnim, backAnim ) =
                    if id == model.selectedCohort then
                        ( ""
                        , Animation.interrupt
                            [ Animation.toWith
                                (Animation.easing
                                    { duration = 0.2 * Time.second
                                    , ease = identity
                                    }
                                )
                                [ Animation.rotate3d (deg 0) (deg 0) (deg 0)
                                , Animation.opacity 1
                                ]
                            ]
                            front
                        , Animation.interrupt
                            [ Animation.toWith
                                (Animation.easing
                                    { duration = 0.2 * Time.second
                                    , ease = identity
                                    }
                                )
                                [ Animation.rotate3d (deg 0) (deg 180) (deg 0)
                                , Animation.opacity 0
                                ]
                            ]
                            back
                        )
                    else
                        ( id
                        , Animation.interrupt
                            [ Animation.toWith
                                (Animation.easing
                                    { duration = 0.2 * Time.second
                                    , ease = identity
                                    }
                                )
                                [ Animation.rotate3d (deg 0) (deg 180) (deg 0)
                                , Animation.opacity 0
                                ]
                            ]
                            front
                        , Animation.interrupt
                            [ Animation.toWith
                                (Animation.easing
                                    { duration = 0.2 * Time.second
                                    , ease = identity
                                    }
                                )
                                [ Animation.rotate3d (deg 0) (deg 0) (deg 0)
                                , Animation.opacity 1
                                ]
                            ]
                            back
                        )

                ( front, back ) =
                    model.cohortAnims
                        |> Dict.get id
                        |> Maybe.withDefault ( frontInit, backInit )

                githubUsernames =
                    model.campuses
                        |> List.concatMap .cohorts
                        |> List.foldl
                            (\{ id, students } acc ->
                                if id == selectedCohort then
                                    List.filterMap .github students
                                else
                                    acc
                            )
                            []

                githubAuth =
                    let
                        ( githubId, gitHubSecret ) =
                            model.githubAuth
                    in
                        "?client_id=" ++ githubId ++ "&client_secret=" ++ gitHubSecret

                usernamesToRequest =
                    githubUsernames
                        |> List.filterMap
                            (\username ->
                                case Dict.get username model.githubImages of
                                    Just (GithubImage _) ->
                                        Nothing

                                    Just Loading ->
                                        Nothing

                                    _ ->
                                        Just username
                            )

                requests =
                    usernamesToRequest
                        |> List.map
                            (\username ->
                                Http.get
                                    ("https://api.github.com/users/"
                                        ++ username
                                        ++ githubAuth
                                    )
                                    (Decode.field "avatar_url" Decode.string)
                                    |> Http.send (CbGithubImage username)
                            )
            in
                { model
                    | selectedCohort = selectedCohort
                    , githubImages =
                        Dict.union
                            (usernamesToRequest
                                |> List.map (flip (,) Loading)
                                |> Dict.fromList
                            )
                            model.githubImages
                    , cohortAnims =
                        model.cohortAnims
                            |> Dict.insert id ( frontAnim, backAnim )
                }
                    ! requests
