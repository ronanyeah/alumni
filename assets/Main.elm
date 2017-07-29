module Main exposing (main)

import Data
import Date
import Date.Extra as Extra
import GraphQL.Client.Http as Gr
import Json.Decode as Decode
import Html exposing (Html, a, br, button, div, input, li, p, text)
import Html.Attributes exposing (href, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Html.Keyed as Keyed
import Http
import Task
import Types exposing (Cohort, Campus, Student, NewCohort)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


type alias Model =
    { campuses : List Campus
    , selectedCampus : Maybe Campus
    , selectedCohort : String
    , newCohort : Maybe NewCohort
    }


init : ( Model, Cmd Msg )
init =
    { campuses = []
    , selectedCampus = Nothing
    , selectedCohort = ""
    , newCohort = Nothing
    }
        ! [ getData ]


emptyNewCohort : NewCohort
emptyNewCohort =
    { startDate = Date.fromTime 1483228800000
    , endDate = Date.fromTime 1488326400000
    , campus = Nothing
    }



-- VIEW


view : Model -> Html Msg
view { campuses, selectedCampus, selectedCohort, newCohort } =
    let
        cohortsView : List Cohort -> Html Msg
        cohortsView =
            List.sortBy (.startDate >> Date.toTime)
                >> List.map
                    (\{ id, startDate, endDate, students } ->
                        let
                            dropdown =
                                if selectedCohort == id then
                                    studentsView students
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
                    |> List.map
                        (\campus ->
                            let
                                dropdown =
                                    case selectedCampus of
                                        Just { id } ->
                                            if campus.id == id then
                                                cohortsView campus.cohorts
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
    | CreateCb (Result Http.Error Decode.Value)
    | Cb (Result Gr.Error (List Campus))
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
                                                Http.send CreateCb <|
                                                    Data.createCohort
                                                        (formatDate startDate)
                                                        (formatDate endDate)
                                                        id
                                            )
                                        |> Maybe.withDefault Cmd.none
                                )
                            |> Maybe.withDefault Cmd.none
                in
                    model ! [ cmd ]

            Cb res ->
                case res of
                    Ok data ->
                        { model | campuses = data } ! []

                    Err err ->
                        model ! [ log "err" err ]

            CreateCb res ->
                case res of
                    Ok data ->
                        { model | newCohort = Nothing } ! [ log "Res" data, getData ]

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


getData : Cmd Msg
getData =
    Data.campusRequest
        |> Gr.sendQuery "/graph?query="
        |> Task.attempt Cb
