module Update exposing (update)

import Api
import Animation exposing (deg)
import Dict
import Element
import Helpers exposing (getCohortAnim, log, sortByStartDate)
import Model exposing (Campus, CampusWithoutNum, Model, Msg(..), GithubImage(..), State(..))
import Murmur3 exposing (hashString)
import Task
import Time


addFacNumbers : List CampusWithoutNum -> List Campus
addFacNumbers =
    List.map
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate animMsg ->
            { model
                | cohortAnims =
                    model.cohortAnims
                        |> Dict.map
                            (\_ ( front, back ) ->
                                ( Animation.update animMsg front
                                , Animation.update animMsg back
                                )
                            )
            }
                ! []

        CbCampuses res ->
            case res of
                Ok campuses ->
                    { model
                        | campuses = addFacNumbers campuses
                    }
                        ! []

                Err err ->
                    model ! [ log "err" err ]

        CbGithubImages requestedUsernames res ->
            case res of
                Ok data ->
                    let
                        imgs =
                            List.foldl
                                (\username dict ->
                                    let
                                        hashedUsername =
                                            "G" ++ (username |> hashString 1234 |> toString)

                                        val =
                                            case Dict.get hashedUsername data of
                                                Just avatarUrl ->
                                                    GithubImage avatarUrl

                                                Nothing ->
                                                    Failed
                                    in
                                        Dict.insert username val dict
                                )
                                model.githubImages
                                requestedUsernames
                    in
                        { model | githubImages = imgs } ! []

                Err err ->
                    model ! [ log "err" err ]

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

                        modelWithAnimations =
                            { model
                                | state = CohortSelected campus cohort
                                , cohortAnims =
                                    model.cohortAnims
                                        |> Dict.insert cohort.id ( frontAnim, backAnim )
                            }
                    in
                        if List.length usernamesToRequest == 0 then
                            modelWithAnimations ! []
                        else
                            let
                                updatedImageDict =
                                    Dict.union
                                        (usernamesToRequest
                                            |> List.map (flip (,) Loading)
                                            |> Dict.fromList
                                        )
                                        model.githubImages

                                imagesRequest =
                                    Task.attempt (CbGithubImages usernamesToRequest) <|
                                        Api.fetchAvatars
                                            model.githubToken
                                            usernamesToRequest
                            in
                                { modelWithAnimations
                                    | githubImages = updatedImageDict
                                }
                                    ! [ imagesRequest ]

                _ ->
                    model ! []
