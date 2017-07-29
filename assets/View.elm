module View exposing (view)

import Date exposing (Date)
import Dict
import Html.Keyed as Keyed
import Helpers
import Html exposing (Html, a, br, button, div, input, li, p, text)
import Html.Attributes exposing (href, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Maybe.Extra as Maybe
import Update exposing (Msg(..))
import Types exposing (Cohort, Student, Model)


view : Model -> Html Msg
view { campuses, cohorts, students, selectedCampus, selectedCohort, cohortForm, studentForm } =
    let
        cohortsView : List Cohort -> Html Msg
        cohortsView =
            sortByStartDate
                >> List.map
                    (\{ id, startDate, endDate } ->
                        let
                            dropdown =
                                if selectedCohort == id then
                                    students
                                        |> Dict.values
                                        |> List.filter (.cohortId >> (==) id)
                                        |> studentsView
                                else
                                    div [] []
                        in
                            ( id
                            , li []
                                [ button [ onClick <| SelectCohort id ] [ dateText startDate endDate ]
                                , dropdown
                                ]
                            )
                    )
                >> Keyed.ol []

        studentsView : List Student -> Html Msg
        studentsView studentList =
            if List.isEmpty studentList then
                p [] [ text "No students!" ]
            else
                Keyed.ul []
                    (studentList
                        |> List.map
                            (\{ id, firstName, lastName, github } ->
                                ( id
                                , li []
                                    [ p [] [ text <| "Name: " ++ firstName ++ " " ++ lastName ]
                                    , p []
                                        [ text <| "GitHub: "
                                        , a
                                            [ href <| "https://github.com/" ++ github
                                            , target "_blank"
                                            ]
                                            [ text <| "/" ++ github ]
                                        ]
                                    ]
                                )
                            )
                    )

        campusesView =
            Keyed.ul []
                (campuses
                    |> Dict.values
                    |> List.map
                        (\{ id, name } ->
                            let
                                dropdown =
                                    if id == selectedCampus then
                                        cohorts
                                            |> Dict.values
                                            |> List.filter (.campusId >> (==) id)
                                            |> cohortsView
                                    else
                                        div [] []
                            in
                                ( id
                                , li []
                                    [ button [ onClick <| SelectCampus id ] [ text name ]
                                    , dropdown
                                    ]
                                )
                        )
                )

        createCohortForm =
            cohortForm
                |> Maybe.unwrap
                    (button
                        [ onClick CohortFormEnable ]
                        [ text "Add Cohort" ]
                    )
                    (\{ startDate, endDate, campusId } ->
                        Dict.get campusId campuses
                            |> Maybe.unwrap
                                (div
                                    []
                                    (text "Please select campus: "
                                        :: (campuses
                                                |> Dict.values
                                                |> List.map
                                                    (\campus ->
                                                        button [ onClick <| CohortFormSetCampus campus.id ]
                                                            [ text campus.name ]
                                                    )
                                           )
                                    )
                                )
                                (\{ name } ->
                                    div []
                                        [ p [] [ text <| "Campus Selected: " ++ name ]
                                        , p [] [ text "Please enter starting and finishing dates:" ]
                                        , input [ type_ "date", dateInputValue startDate, onInput CohortFormSetStartDate ] []
                                        , input [ type_ "date", dateInputValue endDate, onInput CohortFormSetEndDate ] []
                                        , br [] []
                                        , button [ onClick CohortFormSubmit ] [ text "Submit" ]
                                        , button [ onClick CohortFormCancel ] [ text "Cancel" ]
                                        ]
                                )
                    )

        createStudentForm =
            studentForm
                |> Maybe.unwrap
                    (button
                        [ onClick StudentFormEnable ]
                        [ text "Add Student" ]
                    )
                    (\{ cohortId, firstName, lastName, github } ->
                        Dict.get cohortId cohorts
                            |> Maybe.unwrap
                                (div
                                    []
                                    (text "Please select cohort: "
                                        :: (cohorts
                                                |> Dict.values
                                                |> List.indexedMap
                                                    (\i cohort ->
                                                        button [ onClick <| StudentFormSetCohort cohort.id ]
                                                            [ text <| toString i ]
                                                    )
                                           )
                                    )
                                )
                                (\cohort ->
                                    div []
                                        [ p [] [ text <| "Cohort Selected: " ++ cohort.id ]
                                        , p [] [ text "Please enter details:" ]
                                        , input [ type_ "text", value firstName, onInput StudentFormSetFirstName ] []
                                        , input [ type_ "text", value lastName, onInput StudentFormSetLastName ] []
                                        , input [ type_ "text", value github, onInput StudentFormSetGithub ] []
                                        , br [] []
                                        , button [ onClick StudentFormSubmit ] [ text "Submit" ]
                                        , button [ onClick StudentFormCancel ] [ text "Cancel" ]
                                        ]
                                )
                    )
    in
        div []
            [ campusesView
            , createCohortForm
            , createStudentForm
            ]



-- HELPERS


sortByStartDate : List { a | startDate : Date } -> List { a | startDate : Date }
sortByStartDate =
    List.sortBy (.startDate >> Date.toTime)


dateInputValue : Date.Date -> Html.Attribute Msg
dateInputValue =
    Helpers.formatDate >> value


dateText : Date.Date -> Date.Date -> Html Msg
dateText start end =
    let
        render date =
            (date |> Date.month |> toString) ++ " " ++ (date |> Date.year |> toString)
    in
        text (render start ++ " to " ++ render end)
