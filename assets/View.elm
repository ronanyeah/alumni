module View exposing (view)

import Date exposing (Date)
import Dict
import Element exposing (el, text, row, when)
import Element.Attributes as Attr exposing (center, height, px, verticalCenter)
import Element.Events as Events exposing (onClick)
import Element.Keyed as Keyed
import Helpers
import Html exposing (Html)
import Html.Attributes exposing (href, target, type_, value)
import Styling exposing (style, Styles(..))
import Types exposing (Cohort, Student, Model)
import Update exposing (Msg(..))


view : Model -> Html Msg
view { campuses, cohorts, students, selectedCampus, selectedCohort, cohortForm, studentForm } =
    let
        campusesView =
            Element.column None
                [ center, Attr.width (Attr.percent 100) ]
                (campuses
                    |> Dict.values
                    |> List.foldl
                        (\{ id, name } arr ->
                            let
                                drop =
                                    cohorts
                                        |> Dict.values
                                        |> List.filter (.campusId >> (==) selectedCampus)
                                        |> cohortsView

                                new =
                                    el CampusImage
                                        [ Attr.width (Attr.percent 100)
                                        , Attr.height (Attr.px 200)
                                        , onClick <| SelectCampus id
                                        ]
                                    <|
                                        el CampusText [ Attr.padding 7, center, verticalCenter ] <|
                                            Element.text name
                            in
                                if selectedCampus == id then
                                    arr ++ [ new, drop ]
                                else
                                    arr ++ [ new ]
                        )
                        []
                )

        cohortsView xs =
            let
                xsv =
                    Element.when (selectedCohort /= "" && selectedCampus /= "")
                        (students
                            |> Dict.values
                            |> List.filter (.cohortId >> (==) selectedCohort)
                            |> studentsView
                        )
            in
                Element.column None
                    []
                    [ xs
                        |> List.map
                            (\{ id, startDate, endDate } ->
                                ( id
                                , Element.row None
                                    [ onClick <| SelectCohort id ]
                                    [ Element.button <| dateText startDate endDate
                                    ]
                                )
                            )
                        |> Keyed.row None [ center ]
                    , xsv
                    ]

        studentsView studentList =
            if List.isEmpty studentList then
                Element.text "No students!"
            else
                Element.grid None
                    { columns = [ px 100, px 100, px 100, px 100 ]
                    , rows =
                        [ px 100
                        , px 100
                        , px 100
                        , px 100
                        ]
                    }
                    [ center ]
                    (studentList
                        |> List.indexedMap
                            (\i { id, firstName, lastName, github } ->
                                Element.area { start = ( i // 4, rem i 4 ), width = 1, height = 1 }
                                    (Element.textLayout None
                                        []
                                        [ Element.textLayout None [] [ Element.text ("Name: " ++ firstName ++ " " ++ lastName) ]
                                        , Element.text "GitHub: "
                                        , Element.link ("https://github.com/" ++ github) <| Element.text ("/" ++ github)
                                        ]
                                    )
                            )
                    )
    in
        Element.viewport style <|
            Element.column None
                []
                [ Element.row Header
                    [ Attr.paddingXY 0 15, center, verticalCenter ]
                    [ el HeaderText [ Attr.paddingRight 15 ] <| text "Founders & Coders"
                    , Element.image "/logo.png" Image [ height (px 50) ] Element.empty
                    , el HeaderText [ Attr.paddingLeft 15 ] <| text "Alumni"
                    ]
                , campusesView
                ]



-- HELPERS


sortByStartDate : List { a | startDate : Date } -> List { a | startDate : Date }
sortByStartDate =
    List.sortBy (.startDate >> Date.toTime)


dateInputValue : Date.Date -> Html.Attribute Msg
dateInputValue =
    Helpers.formatDate >> value


dateText : Date.Date -> Date.Date -> Element.Element a b c
dateText start end =
    let
        render date =
            (date |> Date.month |> toString) ++ " " ++ (date |> Date.year |> toString)
    in
        Element.text (render start ++ " to " ++ render end)
