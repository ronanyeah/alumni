module Update exposing (update)

import Animation exposing (deg)
import Data
import Date
import Dict exposing (Dict)
import Fixtures exposing (emptyNewCohort, emptyStudentForm, frontInit, backInit)
import Helpers exposing (log)
import GraphQL.Client.Http as Gr
import Maybe.Extra as Maybe
import Model exposing (Cohort, Student, AllData, Model, Msg(..))
import Task
import Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Flip k ->
            let
                ( front, back ) =
                    model.cohortHover
                        |> Dict.get k
                        |> Maybe.withDefault ( frontInit, backInit )

                frontAnim =
                    Animation.interrupt
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

                backAnim =
                    Animation.interrupt
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
            in
                ( { model
                    | cohortHover =
                        model.cohortHover
                            |> Dict.insert k ( frontAnim, backAnim )
                  }
                , Cmd.none
                )

        FlipBack k ->
            let
                ( front, back ) =
                    model.cohortHover
                        |> Dict.get k
                        |> Maybe.withDefault ( frontInit, backInit )

                frontAnim =
                    Animation.interrupt
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

                backAnim =
                    Animation.interrupt
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
            in
                ( { model
                    | cohortHover =
                        model.cohortHover
                            |> Dict.insert k ( frontAnim, backAnim )
                  }
                , Cmd.none
                )

        Animate animMsg ->
            { model
                | cohortHover =
                    Dict.map
                        (\_ ( front, back ) ->
                            ( Animation.update animMsg front, Animation.update animMsg back )
                        )
                        model.cohortHover
            }
                ! []

        CbAllData res ->
            case res of
                Ok { campuses, cohorts, students } ->
                    { model
                        | campuses = dictById campuses
                        , cohorts = dictById cohorts
                        , students = dictById students
                    }
                        ! []

                Err err ->
                    model ! [ log "err" err ]

        CbCreateCohort res ->
            case res of
                Ok data ->
                    { model
                        | cohortForm = Nothing
                        , cohorts = Dict.insert data.id data model.cohorts
                    }
                        ! [ log "Res" data ]

                Err err ->
                    { model | cohortForm = Nothing } ! [ log "Err" err ]

        CbCreateStudent res ->
            case res of
                Ok data ->
                    { model
                        | studentForm = Nothing
                        , students = Dict.insert data.id data model.students
                    }
                        ! [ log "Res" data ]

                Err err ->
                    { model | cohortForm = Nothing } ! [ log "Err" err ]

        CohortFormCancel ->
            { model | cohortForm = Nothing } ! []

        CohortFormEnable ->
            { model | cohortForm = Just emptyNewCohort } ! []

        CohortFormSetCampus campusId ->
            case model.cohortForm of
                Just form ->
                    { model | cohortForm = Just { form | campusId = campusId } } ! []

                Nothing ->
                    model ! []

        CohortFormSetEndDate str ->
            let
                newDate =
                    dateFromString str

                cohortForm =
                    model.cohortForm
                        |> Maybe.map
                            (\form ->
                                { form | endDate = newDate }
                            )
            in
                { model | cohortForm = cohortForm } ! []

        CohortFormSetStartDate str ->
            let
                newDate =
                    dateFromString str

                cohortForm =
                    model.cohortForm
                        |> Maybe.map
                            (\form ->
                                { form | startDate = newDate }
                            )
            in
                { model | cohortForm = cohortForm } ! []

        CohortFormSubmit ->
            let
                cmd =
                    model.cohortForm
                        |> Maybe.unwrap
                            Cmd.none
                            (\form ->
                                Data.mutationNewCohort form
                                    |> Gr.sendMutation "/graph?query="
                                    |> Task.attempt CbCreateCohort
                            )
            in
                model ! [ cmd ]

        SelectCampus campusId ->
            let
                selectedCampus =
                    if campusId == model.selectedCampus then
                        ""
                    else
                        campusId
            in
                { model | selectedCampus = selectedCampus, selectedCohort = "" } ! []

        SelectCohort id ->
            let
                selectedCohort =
                    if id == model.selectedCohort then
                        ""
                    else
                        id
            in
                { model | selectedCohort = selectedCohort } ! []

        StudentFormCancel ->
            { model | studentForm = Nothing } ! []

        StudentFormEnable ->
            { model | studentForm = Just emptyStudentForm } ! []

        StudentFormSetFirstName str ->
            let
                newModel =
                    model.studentForm
                        |> Maybe.unwrap
                            model
                            (\form ->
                                { model
                                    | studentForm =
                                        Just { form | firstName = str }
                                }
                            )
            in
                newModel ! []

        StudentFormSetLastName str ->
            let
                newModel =
                    model.studentForm
                        |> Maybe.unwrap
                            model
                            (\form ->
                                { model
                                    | studentForm =
                                        Just { form | lastName = str }
                                }
                            )
            in
                newModel ! []

        StudentFormSetCohort str ->
            let
                newModel =
                    model.studentForm
                        |> Maybe.unwrap
                            model
                            (\form ->
                                { model
                                    | studentForm =
                                        Just { form | cohortId = str }
                                }
                            )
            in
                newModel ! []

        StudentFormSetGithub str ->
            let
                newModel =
                    model.studentForm
                        |> Maybe.unwrap
                            model
                            (\form ->
                                { model
                                    | studentForm =
                                        Just { form | github = str }
                                }
                            )
            in
                newModel ! []

        StudentFormSubmit ->
            let
                cmd =
                    model.studentForm
                        |> Maybe.unwrap
                            Cmd.none
                            (\form ->
                                Data.mutationNewStudent form
                                    |> Gr.sendMutation "/graph?query="
                                    |> Task.attempt CbCreateStudent
                            )
            in
                model ! [ cmd ]



-- HELPERS


dictById : List { x | id : String } -> Dict String { x | id : String }
dictById =
    List.map (\x -> ( x.id, x )) >> Dict.fromList


dateFromString : String -> Date.Date
dateFromString =
    Date.fromString >> Result.withDefault (Date.fromTime 1483228800000)
