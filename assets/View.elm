module View exposing (view)

import Animation
import Dict
import List.Extra exposing (greedyGroupsOf)
import Element exposing (Element, circle, column, empty, el, image, link, text, row, viewport, when, whenJust)
import Element.Attributes as Attr exposing (center, height, padding, paddingXY, px, spacing, verticalCenter, width)
import Element.Events as Events exposing (onClick)
import Fixtures exposing (frontInit, backInit)
import Helpers exposing (cohortText, sortByStartDate)
import Html exposing (Html)
import Styling exposing (styling, Styles(..))
import Model exposing (Model, Campus, Cohort, CohortAnims, Student, Msg(..))


view : Model -> Html Msg
view { campuses, selectedCampus, selectedCohort, cohortAnims } =
    viewport styling <|
        column None
            []
            [ row Header
                [ paddingXY 0 15, center, verticalCenter ]
                [ link "https://foundersandcoders.com/" <|
                    el None
                        [ Attr.target "_blank"
                        ]
                    <|
                        image "/logo.png" Image [ height (px 50) ] empty
                ]
            , campusesView campuses selectedCohort selectedCampus cohortAnims
            ]


campusesView : List Campus -> String -> String -> CohortAnims -> Element Styles variation Msg
campusesView campuses selectedCohort selectedCampus cohortAnims =
    column None
        [ center, Attr.width (Attr.percent 100), verticalCenter ]
        (campuses
            |> List.foldl
                (\{ id, name, cohorts } arr ->
                    let
                        campus =
                            row None
                                [ center
                                , verticalCenter
                                , onClick <| SelectCampus id
                                ]
                                [ el Words [ verticalCenter ] <| text <| String.toUpper name ]

                        indexedCohorts =
                            cohorts
                                |> sortByStartDate
                                |> List.indexedMap (,)
                                |> List.map (Tuple.mapFirst ((+) 1))

                        dropdown =
                            if selectedCohort == "" then
                                viewCohorts indexedCohorts cohortAnims
                            else
                                indexedCohorts
                                    |> List.filter (Tuple.second >> (.id >> (==) selectedCohort))
                                    |> List.head
                                    |> flip whenJust (viewSingleCohort cohortAnims)
                    in
                        arr
                            ++ [ campus
                               , when (selectedCampus == id) dropdown
                               ]
                )
                []
        )


viewSingleCohort : CohortAnims -> ( Int, Cohort ) -> Element Styles variation Msg
viewSingleCohort cohortAnims ( i, { id, startDate, endDate, students } ) =
    column None
        []
        [ let
            anims =
                cohortAnims
                    |> Dict.get id
                    |> Maybe.withDefault ( frontInit, backInit )
          in
            cohortCircle anims (cohortText startDate endDate) i id
        , viewStudents students
        ]


viewCohorts : List ( Int, Cohort ) -> CohortAnims -> Element Styles variation Msg
viewCohorts cohorts cohortAnims =
    let
        content =
            if List.isEmpty cohorts then
                [ text "No students!" ]
            else
                cohorts
                    |> List.map
                        (\( i, { id, startDate, endDate } ) ->
                            let
                                anims =
                                    cohortAnims
                                        |> Dict.get id
                                        |> Maybe.withDefault ( frontInit, backInit )

                                datesText =
                                    cohortText startDate endDate
                            in
                                cohortCircle anims datesText i id
                        )
                    |> greedyGroupsOf 3
                    |> List.map (row None [ spacing 5 ])
    in
        column None
            [ Attr.paddingBottom 15 ]
            [ column None [ center ] content ]


viewStudents : List Student -> Element Styles variation Msg
viewStudents students =
    if List.isEmpty students then
        text "No students!"
    else
        column None
            [ center, padding 20 ]
            (students
                |> List.map
                    (\{ firstName, github } ->
                        column None
                            [ width <| px 100, height <| px 100, center, padding 5 ]
                            [ image "http://lorempixel.com/200/200/people/"
                                StudentImg
                                [ width <| px 50
                                , height <| px 50
                                , padding 3
                                ]
                                empty
                            , el HeaderText [ padding 3 ] <| text firstName
                            , link ("https://github.com/" ++ github) <|
                                el None
                                    [ Attr.target "_blank"
                                    , padding 3
                                    ]
                                <|
                                    image "/gh.svg" None [] empty
                            ]
                    )
                |> greedyGroupsOf 4
                |> List.map (row None [])
            )


renderAnim : Animation.State -> List (Element.Attribute variation Msg) -> List (Element.Attribute variation Msg)
renderAnim animStyle otherAttrs =
    animStyle
        |> Animation.render
        |> List.map Attr.toAttr
        |> (++) otherAttrs


cohortCircle : ( Animation.State, Animation.State ) -> String -> Int -> String -> Element Styles v Msg
cohortCircle ( frontAnim, backAnim ) txt num id =
    let
        front =
            circle 100
                CampusCircle
                (renderAnim frontAnim [ center, height <| px 200, width <| px 200, verticalCenter ])
            <|
                el Num [ center, verticalCenter ] <|
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
