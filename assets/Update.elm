module Update exposing (update, Msg(..))

import Data
import Date
import Dict exposing (Dict)
import Fixtures exposing (emptyNewCohort, emptyStudentForm)
import GraphQL.Client.Http as Gr
import Maybe.Extra as Maybe
import Types exposing (Cohort, Student, AllData, Model)
import Task


type Msg
    = CbAllData (Result Gr.Error AllData)
    | CbCreateCohort (Result Gr.Error Cohort)
    | CbCreateStudent (Result Gr.Error Student)
    | CohortFormCancel
    | CohortFormEnable
    | CohortFormSetCampus String
    | CohortFormSetEndDate String
    | CohortFormSetStartDate String
    | CohortFormSubmit
    | SelectCampus String
    | SelectCohort String
    | StudentFormCancel
    | StudentFormEnable
    | StudentFormSetCohort String
    | StudentFormSetFirstName String
    | StudentFormSetLastName String
    | StudentFormSetGithub String
    | StudentFormSubmit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        log l v =
            let
                _ =
                    Debug.log l v
            in
                Cmd.none
    in
        case msg of
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
