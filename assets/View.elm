module View exposing (view)

import Dict exposing (Dict)
import Element exposing (Device, Element, circle, column, empty, el, image, link, text, row, viewport, whenJust)
import Element.Attributes exposing (center, height, padding, paddingBottom, paddingLeft, paddingRight, paddingXY, percent, px, spacing, target, vary, verticalCenter, width)
import Element.Events exposing (onClick)
import Helpers exposing (cohortText, getCohortAnim, renderAnim)
import Html exposing (Html)
import List.Extra exposing (greedyGroupsOf)
import Model exposing (Model, Campus, Cohort, CohortAnim, GithubImage(..), State(..), Student, Msg(..))
import Styling exposing (styling, Styles(..), Variations(..))


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
                        , viewCohort device anim cohort DeselectCohort
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
            link "https://foundersandcoders.com/" <|
                el None [ target "_blank", paddingXY 0 15, center, verticalCenter ] <|
                    image "/logo.png" Image [ height (px 50) ] empty
    in
        if phone then
            logo
        else
            logo
                |> Element.onRight
                    [ el HeaderText
                        [ paddingLeft 15
                        , verticalCenter
                        ]
                      <|
                        text "Alumni"
                    ]
                |> Element.onLeft
                    [ el HeaderText
                        [ paddingRight 15
                        , verticalCenter
                        , width <| px 160
                        ]
                      <|
                        text "Founders & Coders"
                    ]


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
                |> List.map (row None [ spacing 5 ])
    in
        column None [ center, paddingBottom 15 ] content


viewCohort : Device -> CohortAnim -> Cohort -> Msg -> Element Styles Variations Msg
viewCohort device ( frontAnim, backAnim ) cohort clickMsg =
    let
        datesText =
            cohortText cohort.startDate cohort.endDate

        size =
            if device.phone then
                120
            else
                200

        side anim style txt =
            circle (size / 2)
                CampusCircle
                (renderAnim anim [ center, verticalCenter ])
            <|
                el style [ center, verticalCenter ] <|
                    text txt
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
                [ side frontAnim Num <| toString cohort.num
                , side backAnim None datesText
                ]


viewStudents : Device -> Dict String GithubImage -> List Student -> Element Styles Variations Msg
viewStudents device githubImages students =
    column None
        [ center ]
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
            |> greedyGroupsOf 4
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
    in
        column None
            [ width <| px 100, height <| px 100, center, padding 5 ]
            [ image imgSrc
                StudentImg
                [ width <| px 50
                , height <| px 50
                , padding 3
                ]
                empty
            , el HeaderText [ padding 3 ] <| text firstName
            , whenJust github
                (\username ->
                    link ("https://github.com/" ++ username) <|
                        el None
                            [ target "_blank"
                            , padding 3
                            ]
                        <|
                            image "/gh.svg" None [] empty
                )
            ]
