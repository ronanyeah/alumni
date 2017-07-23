module Main exposing (main)

import Data
import Date
import Html exposing (Html, li, p, text)
import Html.Keyed as Keyed
import Http
import Types exposing (Cohort, Campus, Student)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


type alias Model =
    { campuses : List Campus }


init : ( Model, Cmd Msg )
init =
    { campuses = [] } ! [ Http.send Cb Data.all ]



-- VIEW


view : Model -> Html Msg
view =
    .campuses >> campusesView


campusesView : List Campus -> Html Msg
campusesView =
    List.map
        (\{ id, name, cohorts } ->
            ( id
            , li []
                [ text name
                , cohortsView cohorts
                ]
            )
        )
        >> Keyed.ul []


cohortsView : List Cohort -> Html Msg
cohortsView =
    List.sortBy (.startDate >> Date.toTime)
        >> List.map
            (\{ id, startDate, endDate, students } ->
                ( id
                , li []
                    [ dateText startDate endDate
                    , studentsView students
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
                , p [] [ text <| "GitHub: " ++ github ]
                ]
            )
        )
        >> Keyed.ul []


dateText : Date.Date -> Date.Date -> Html Msg
dateText start end =
    let
        render date =
            (date |> Date.month |> toString) ++ " " ++ (date |> Date.year |> toString)
    in
        text (render start ++ " to " ++ render end)



-- UPDATE


type Msg
    = Cb (Result Http.Error (List Campus))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        errLog e =
            let
                _ =
                    Debug.log "Err" e
            in
                Cmd.none
    in
        case msg of
            Cb res ->
                case res of
                    Ok data ->
                        { model | campuses = data } ! []

                    Err err ->
                        model ! [ errLog err ]
