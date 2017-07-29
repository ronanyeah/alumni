module Main exposing (main)

import Data
import Date
import Dict exposing (Dict)
import Date.Extra as Extra
import GraphQL.Client.Http as Gr
import Html exposing (Html, a, br, button, div, input, li, p, text)
import Html.Attributes exposing (href, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed
import Task
import Types exposing (Cohort, Campus, Student, NewCohort, AllData)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


type alias Model =
    { campuses : Dict String Campus
    , cohorts : Dict String Cohort
    , students : Dict String Student
    , selectedCampus : Maybe Campus
    , selectedCohort : String
    , newCohort : Maybe NewCohort
    }


init : ( Model, Cmd Msg )
init =
    { campuses = Dict.empty
    , cohorts = Dict.empty
    , students = Dict.empty
    , selectedCampus = Nothing
    , selectedCohort = ""
    , newCohort = Nothing
    }
        ! [ Data.queryAllData
                |> Gr.sendQuery "/graph?query="
                |> Task.attempt CbAllData
          ]


emptyNewCohort : NewCohort
emptyNewCohort =
    { startDate = Date.fromTime 1483228800000
    , endDate = Date.fromTime 1488326400000
    , campus = Nothing
    }



-- VIEW


view : Model -> Html Msg
view { campuses, cohorts, students, selectedCampus, selectedCohort, newCohort } =
    let
        cohortsView : List Cohort -> Html Msg
        cohortsView =
            List.sortBy (.startDate >> Date.toTime)
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
                                [ button [ onClick <| SetCohort id ] [ dateText startDate endDate ]
                                , dropdown
                                ]
                            )
                    )
                >> Keyed.ol []

        studentsView : List Student -> Html Msg
        studentsView =
            List.map
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
                >> Keyed.ul []
    in
        div []
            [ Keyed.ul []
                (campuses
                    |> Dict.values
                    |> List.map
                        (\campus ->
                            let
                                dropdown =
                                    case selectedCampus of
                                        Just { id } ->
                                            if campus.id == id then
                                                cohorts
                                                    |> Dict.values
                                                    |> List.filter (.campusId >> (==) id)
                                                    |> cohortsView
                                            else
                                                div [] []

                                        Nothing ->
                                            div [] []
                            in
                                ( campus.id
                                , li []
                                    [ button [ onClick <| SetCampus campus ] [ text campus.name ]
                                    , dropdown
                                    ]
                                )
                        )
                )
            , case newCohort of
                Just { startDate, endDate, campus } ->
                    case campus of
                        Just { name } ->
                            div []
                                [ p [] [ text <| "Campus: " ++ name ]
                                , p [] [ text "Please enter starting and finishing dates:" ]
                                , input [ type_ "date", dateInputValue startDate, onInput SetStartDate ] []
                                , input [ type_ "date", dateInputValue endDate, onInput SetEndDate ] []
                                , br [] []
                                , button [ onClick AddCohortSubmit ] [ text "Submit" ]
                                , button [ onClick AddCohortCancel ] [ text "Cancel" ]
                                ]

                        Nothing ->
                            p [] [ text "Please select campus." ]

                Nothing ->
                    button [ onClick AddCohort ] [ text "Add Cohort" ]
            ]


dateInputValue : Date.Date -> Html.Attribute Msg
dateInputValue =
    formatDate >> value


formatDate : Date.Date -> String
formatDate =
    Extra.toFormattedString "yyyy-MM-dd"


dateText : Date.Date -> Date.Date -> Html Msg
dateText start end =
    let
        render date =
            (date |> Date.month |> toString) ++ " " ++ (date |> Date.year |> toString)
    in
        text (render start ++ " to " ++ render end)



-- UPDATE


type Msg
    = AddCohort
    | AddCohortCancel
    | AddCohortSubmit
    | CbCreateCohort (Result Gr.Error Cohort)
    | CbAllData (Result Gr.Error AllData)
    | SetCampus Campus
    | SetCohort String
    | SetStartDate String
    | SetEndDate String


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
            AddCohort ->
                { model | newCohort = Just emptyNewCohort } ! []

            AddCohortCancel ->
                { model | newCohort = Nothing } ! []

            AddCohortSubmit ->
                let
                    cmd =
                        model.newCohort
                            |> Maybe.map
                                (\{ startDate, endDate, campus } ->
                                    campus
                                        |> Maybe.map
                                            (\{ id } ->
                                                Data.mutationNewCohort
                                                    (formatDate startDate)
                                                    (formatDate endDate)
                                                    id
                                                    |> Gr.sendMutation "/graph?query="
                                                    |> Task.attempt CbCreateCohort
                                            )
                                        |> Maybe.withDefault Cmd.none
                                )
                            |> Maybe.withDefault Cmd.none
                in
                    model ! [ cmd ]

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
                            | newCohort = Nothing
                            , cohorts = Dict.insert data.id data model.cohorts
                        }
                            ! [ log "Res" data ]

                    Err err ->
                        { model | newCohort = Nothing } ! [ log "Err" err ]

            SetCampus campus ->
                case model.newCohort of
                    Just form ->
                        { model | newCohort = Just { form | campus = Just campus } } ! []

                    Nothing ->
                        let
                            selectedCampus =
                                case model.selectedCampus of
                                    Just selCampus ->
                                        if campus.id == selCampus.id then
                                            Nothing
                                        else
                                            Just campus

                                    Nothing ->
                                        Just campus
                        in
                            { model | selectedCampus = selectedCampus } ! []

            SetCohort id ->
                let
                    selectedCohort =
                        if id == model.selectedCohort then
                            ""
                        else
                            id
                in
                    { model | selectedCohort = selectedCohort } ! []

            SetStartDate str ->
                let
                    newDate =
                        case Date.fromString str of
                            Ok d ->
                                d

                            _ ->
                                Date.fromTime 1483228800000

                    newCohort =
                        model.newCohort
                            |> Maybe.map
                                (\form ->
                                    { form | startDate = newDate }
                                )
                in
                    { model | newCohort = newCohort } ! []

            SetEndDate str ->
                let
                    newDate =
                        case Date.fromString str of
                            Ok d ->
                                d

                            _ ->
                                Date.fromTime 1483228800000

                    newCohort =
                        model.newCohort
                            |> Maybe.map
                                (\form ->
                                    { form | endDate = newDate }
                                )
                in
                    { model | newCohort = newCohort } ! []



-- HELPERS


dictById : List { x | id : String } -> Dict String { x | id : String }
dictById =
    List.map (\x -> ( x.id, x )) >> Dict.fromList
