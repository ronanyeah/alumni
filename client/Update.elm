module Update exposing (update)

import Animation exposing (deg)
import Dict
import Element
import Json.Decode as Decode
import Helpers exposing (getCohortAnim, log, sortByStartDate)
import Http
import Model exposing (Model, Msg(..), GithubImage(..), State(..))
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
                Ok campuses ->
                    let
                        data =
                            campuses
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
            { model | state = CampusSelected campus } ! []

        DeselectCampus ->
            { model | state = NothingSelected, cohortAnims = Dict.empty } ! []

        DeselectCohort ->
            case model.state of
                CohortSelected campus cohort ->
                    let
                        ( frontAnim, backAnim ) =
                            let
                                ( frontInit, backInit ) =
                                    getCohortAnim cohort model.cohortAnims
                            in
                                ( Animation.interrupt
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
                                    frontInit
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
                                    backInit
                                )
                    in
                        { model
                            | state = CampusSelected campus
                            , cohortAnims =
                                model.cohortAnims
                                    |> Dict.insert cohort.id ( frontAnim, backAnim )
                        }
                            ! []

                _ ->
                    model ! []

        SelectCohort cohort ->
            case model.state of
                CampusSelected campus ->
                    let
                        ( frontAnim, backAnim ) =
                            let
                                ( frontInit, backInit ) =
                                    getCohortAnim cohort model.cohortAnims
                            in
                                ( Animation.interrupt
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
                                    frontInit
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
                                    backInit
                                )

                        githubUsernames =
                            cohort.students
                                |> List.filterMap .github

                        usernamesToRequest =
                            githubUsernames
                                |> List.filterMap
                                    (\username ->
                                        case Dict.get username model.githubImages of
                                            Just (GithubImage _) ->
                                                Nothing

                                            Just Loading ->
                                                Nothing

                                            Just Failed ->
                                                Nothing

                                            Nothing ->
                                                Just username
                                    )

                        requests =
                            let
                                ( githubId, gitHubSecret ) =
                                    model.githubAuth

                                githubAuth =
                                    "?client_id=" ++ githubId ++ "&client_secret=" ++ gitHubSecret
                            in
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
                            | state = CohortSelected campus cohort
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

                _ ->
                    model ! []
