module View exposing (view)

import Animation exposing (deg)
import Date exposing (Date)
import Dict
import List.Extra exposing (greedyGroupsOf)
import Element exposing (Element, circle, column, empty, el, image, link, text, row, viewport, when, whenJust)
import Element.Attributes as Attr exposing (center, height, padding, paddingXY, percent, px, spacing, verticalCenter, width)
import Element.Events as Events exposing (onClick)
import Fixtures exposing (frontInit, backInit)
import Html exposing (Html)
import Styling exposing (styling, Styles(..))
import Model exposing (Model, Msg(..))


view : Model -> Html Msg
view { campuses, cohorts, students, selectedCampus, selectedCohort, cohortHover } =
    let
        campusesView =
            let
                section =
                    if selectedCohort /= "" && selectedCampus /= "" then
                        column None
                            []
                            [ Dict.get selectedCohort cohorts
                                |> flip whenJust
                                    (\{ id, startDate, endDate } ->
                                        let
                                            facNum =
                                                cohorts
                                                    |> Dict.values
                                                    |> List.filter (.campusId >> (==) selectedCampus)
                                                    |> sortByStartDate
                                                    |> List.indexedMap (,)
                                                    |> List.filter (Tuple.second >> .id >> (==) id)
                                                    |> List.head
                                                    |> Maybe.map (Tuple.first >> (+) 1)
                                                    |> Maybe.withDefault 0

                                            anims =
                                                cohortHover
                                                    |> Dict.get id
                                                    |> Maybe.withDefault ( frontInit, backInit )
                                        in
                                            cohortCircle anims (cohortText startDate endDate) facNum id
                                    )
                            , students
                                |> Dict.values
                                |> List.filter (.cohortId >> (==) selectedCohort)
                                |> studentsView
                            ]
                    else
                        cohorts
                            |> Dict.values
                            |> List.filter (.campusId >> (==) selectedCampus)
                            |> cohortsView
            in
                column None
                    [ center, Attr.width (Attr.percent 100), verticalCenter ]
                    (campuses
                        |> Dict.values
                        |> List.foldl
                            (\{ id, name } arr ->
                                let
                                    campusImage =
                                        el CampusImage
                                            [ width (percent 100)
                                            , height (px 200)
                                            , onClick <| SelectCampus id
                                            ]
                                        <|
                                            el CampusText [ padding 7, center, verticalCenter ] <|
                                                text name

                                    pic =
                                        row None
                                            [ center
                                            , verticalCenter
                                            , onClick <| SelectCampus id
                                            ]
                                            [ el Words [ verticalCenter ] <| text <| String.toUpper name ]
                                in
                                    arr
                                        ++ [ pic
                                           , when (selectedCampus == id) section
                                           ]
                            )
                            []
                    )

        cohortsView xs =
            let
                xsv =
                    when (selectedCohort /= "" && selectedCampus /= "")
                        (students
                            |> Dict.values
                            |> List.filter (.cohortId >> (==) selectedCohort)
                            |> studentsView
                        )

                grid =
                    column None
                        [ center ]
                        (xs
                            |> sortByStartDate
                            |> List.indexedMap
                                (\i { id, startDate, endDate } ->
                                    let
                                        anims =
                                            cohortHover
                                                |> Dict.get id
                                                |> Maybe.withDefault ( frontInit, backInit )
                                    in
                                        cohortCircle anims (cohortText startDate endDate) (i + 1) id
                                )
                            |> greedyGroupsOf 3
                            |> List.map (row None [ spacing 5 ])
                        )
            in
                column None
                    [ Attr.paddingBottom 15 ]
                    [ grid
                    , xsv
                    ]

        studentsView studentList =
            if List.isEmpty studentList then
                text "No students!"
            else
                column None
                    [ center, padding 20 ]
                    (studentList
                        |> List.map
                            (\{ firstName, github } ->
                                column None
                                    [ width <| px 100, height <| px 100, center, padding 5 ]
                                    [ image "http://lorempixel.com/200/200/people/" StudentImg [ width <| px 50, height <| px 50, padding 3 ] empty
                                    , el HeaderText [ padding 3 ] <| text firstName
                                    , link ("https://github.com/" ++ github) <| el None [ Attr.target "_blank", padding 3 ] <| image "/gh.svg" None [] empty
                                    ]
                            )
                        |> greedyGroupsOf 4
                        |> List.map (row None [])
                    )
    in
        viewport styling <|
            column None
                []
                [ row Header
                    [ paddingXY 0 15, center, verticalCenter ]
                    [ el HeaderText [ Attr.paddingRight 15 ] <| text "Founders & Coders"
                    , image "/logo.png" Image [ height (px 50) ] empty
                    , el HeaderText [ Attr.paddingLeft 15 ] <| text "Alumni"
                    ]
                , campusesView
                ]


renderAnim : Animation.State -> List (Element.Attribute variation Msg) -> List (Element.Attribute variation Msg)
renderAnim animStyle otherAttrs =
    animStyle
        |> Animation.render
        |> List.map Attr.toAttr
        |> (++) otherAttrs



-- HELPERS


cohortCircle : ( Animation.State, Animation.State ) -> String -> Int -> String -> Element Styles v Msg
cohortCircle ( frontAnim, backAnim ) txt num id =
    let
        front =
            circle 100
                CampusCircle
                (renderAnim frontAnim [ center, height <| px 200, width <| px 200, verticalCenter ])
            <|
                el None [ center, verticalCenter ] <|
                    text <|
                        toString num

        back =
            circle 100
                CampusCircle
                (renderAnim backAnim [ center, height <| px 200, width <| px 200, verticalCenter ])
            <|
                el None [ center, verticalCenter ] <|
                    text txt
    in
        el None
            [ Events.onMouseOver <| Flip id
            , onClick <| SelectCohort id
            , Events.onMouseLeave <| FlipBack id
            , height <| px 200
            , width <| px 200
            , center
            ]
            empty
            |> Element.within [ front, back ]


sortByStartDate : List { a | startDate : Date } -> List { a | startDate : Date }
sortByStartDate =
    List.sortBy (.startDate >> Date.toTime)


cohortText : Date.Date -> Date.Date -> String
cohortText start end =
    let
        render date =
            (date |> Date.month |> toString) ++ " " ++ (date |> Date.year |> toString)
    in
        render start ++ " to " ++ render end
