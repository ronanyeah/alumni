module View exposing (view)

import Dict exposing (Dict)
import Element exposing (Device, Element, circle, column, el, empty, image, newTab, row, text, viewport, whenJust)
import Element.Attributes exposing (center, height, padding, paddingBottom, paddingLeft, paddingRight, paddingTop, paddingXY, percent, px, spacing, vary, verticalCenter, width)
import Element.Events exposing (onClick)
import Helpers exposing (cohortText, getCohortAnim, renderAnim)
import Html exposing (Html)
import List.Extra exposing (greedyGroupsOf)
import Model exposing (Campus, Cohort, CohortAnim, GithubImage(..), Model, Msg(..), State(..), Student)
import Styling exposing (Styles(..), Variations(..), styling)


view : Model -> Html Msg
view { campuses, state, cohortAnims, githubImages, device } =
    let
        body =
            case state of
                NothingSelected ->
                    [ viewCampuses device campuses ]

                CampusSelected campus ->
                    [ viewCampus device campus DeselectCampus
                    , viewCohorts device cohortAnims campus.cohorts
                    ]

                CohortSelected campus cohort ->
                    let
                        anim =
                            getCohortAnim cohort cohortAnims
                    in
                    [ viewCampus device campus DeselectCampus
                    , el None [ padding 5 ] <| viewCohort device anim cohort DeselectCohort
                    , viewStudents device githubImages cohort.students
                    ]
    in
    viewport styling <|
        column None
            []
            [ header device
            , column None
                [ center
                , verticalCenter
                ]
                body
            ]


header : Device -> Element Styles variation Msg
header { phone } =
    let
        logo =
            newTab "https://foundersandcoders.com/" <|
                image None [ height <| px 50 ] { src = "/logo.png", caption = "FAC Logo" }
    in
    if phone then
        el None [ center, padding 20 ] <| logo
    else
        el None [ center, padding 20 ] <|
            (logo
                |> Element.onRight
                    [ el Text
                        [ paddingLeft 15
                        , verticalCenter
                        ]
                      <|
                        text "Alumni"
                    ]
                |> Element.onLeft
                    [ el Text
                        [ paddingRight 15
                        , verticalCenter
                        ]
                      <|
                        text "Founders & Coders"
                    ]
            )


viewCampuses : Device -> List Campus -> Element Styles Variations Msg
viewCampuses device =
    List.map
        (\campus ->
            viewCampus device campus (SelectCampus campus)
        )
        >> column None
            [ center, width <| percent 100, verticalCenter ]


viewCampus : Device -> Campus -> Msg -> Element Styles Variations Msg
viewCampus device campus clickMsg =
    el CampusText
        [ center
        , verticalCenter
        , onClick clickMsg
        , vary Mobile device.phone
        ]
    <|
        text <|
            String.toUpper campus.name


viewCohorts : Device -> Dict String CohortAnim -> List Cohort -> Element Styles Variations Msg
viewCohorts device cohortAnims cohorts =
    let
        cohortsWithAnimations : List ( CohortAnim, Cohort )
        cohortsWithAnimations =
            cohorts
                |> List.map
                    (\cohort ->
                        let
                            anim =
                                getCohortAnim cohort cohortAnims
                        in
                        ( anim, cohort )
                    )

        content =
            cohortsWithAnimations
                |> List.map
                    (\( anim, cohort ) ->
                        viewCohort device anim cohort (SelectCohort cohort)
                    )
                |> greedyGroupsOf 3
                |> List.map (row None [ spacing 5, padding 5 ])
    in
    column None [ center, paddingBottom 15 ] content


viewCohort : Device -> CohortAnim -> Cohort -> Msg -> Element Styles Variations Msg
viewCohort device ( frontAnim, backAnim ) cohort clickMsg =
    let
        size =
            if device.phone then
                device.width
                    |> toFloat
                    |> (*) 0.3
            else
                200

        front =
            circle (size / 2)
                CampusCircle
                (renderAnim frontAnim [ center, verticalCenter ])
            <|
                el CohortNum [ vary Mobile device.phone, center, verticalCenter ] <|
                    text <|
                        toString cohort.num

        back =
            circle (size / 2)
                CampusCircle
                (renderAnim backAnim [ center, verticalCenter ])
            <|
                el CohortDates [ vary Mobile device.phone, center, verticalCenter ] <|
                    text <|
                        cohortText cohort.startDate cohort.endDate
    in
    el None
        [ onClick clickMsg
        , height <| px size
        , width <| px size
        , center
        , padding 5
        ]
        empty
        |> Element.within
            [ front
            , back
            ]


viewStudents : Device -> Dict String GithubImage -> List Student -> Element Styles Variations Msg
viewStudents device githubImages students =
    column None
        [ center, paddingTop 20 ]
        (students
            |> List.map
                (\student ->
                    let
                        githubImage =
                            student.github
                                |> Maybe.andThen (flip Dict.get githubImages)
                                |> Maybe.withDefault Failed
                    in
                    viewStudent device githubImage student
                )
            |> greedyGroupsOf
                (if device.phone then
                    3
                 else
                    4
                )
            |> List.map (row None [])
        )


viewStudent : Device -> GithubImage -> Student -> Element Styles Variations Msg
viewStudent device githubImage { firstName, github } =
    let
        imgSrc =
            case githubImage of
                GithubImage img ->
                    img

                Loading ->
                    "/spin.svg"

                Failed ->
                    "/logo.png"

        colWidth =
            if device.phone then
                device.width
                    |> flip (//) 4
                    |> toFloat
                    |> px
                    |> width
            else
                width <| px 90
    in
    column None
        [ center, colWidth, paddingBottom 10 ]
        [ image
            StudentImg
            [ width <| px 50
            , height <| px 50
            ]
            { src = imgSrc, caption = "Student Image" }
        , el Text [ padding 10 ] <| text firstName
        , whenJust github
            (\username ->
                newTab ("https://github.com/" ++ username) <|
                    image None [] { src = "/gh.svg", caption = "Github Link" }
            )
        ]
