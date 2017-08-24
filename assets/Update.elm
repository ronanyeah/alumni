module Update exposing (update)

import Animation exposing (deg)
import Dict
import Element
import Fixtures exposing (frontInit, backInit)
import Json.Decode as Decode
import Helpers exposing (log, sortByStartDate)
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
                    let
                        data =
                            allCampuses
                                |> List.map
                                    (\campus ->
                                        let
                                            numberedCohorts =
                                                campus.cohorts
                                                    |> sortByStartDate
                                                    |> List.indexedMap
                                                        (\i cohort ->
                                                            { id = cohort.id
                                                            , startDate = cohort.startDate
                                                            , endDate = cohort.endDate
                                                            , students = cohort.students
                                                            , num = i + 1
                                                            }
                                                        )
                                        in
                                            { campus | cohorts = numberedCohorts }
                                    )
                    in
                        { model
                            | campuses = data
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

        Resize size ->
            { model | device = Element.classifyDevice size } ! []

        SelectCampus campus ->
            let
                selectedCampus =
                    if Just campus == model.selectedCampus then
                        Nothing
                    else
                        Just campus
            in
                { model | selectedCampus = selectedCampus, selectedCohort = Nothing, cohortAnims = Dict.empty } ! []

        SelectCohort cohort ->
            let
                ( selectedCohort, frontAnim, backAnim ) =
                    if Just cohort == model.selectedCohort then
                        ( Nothing
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
                        ( Just cohort
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
                        |> Dict.get cohort.id
                        |> Maybe.withDefault ( frontInit, backInit )

                githubUsernames =
                    List.filterMap .github cohort.students

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
                            |> Dict.insert cohort.id ( frontAnim, backAnim )
                }
                    ! requests
