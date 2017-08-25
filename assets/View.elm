module View exposing (view)

import Animation
import Dict exposing (Dict)
import Element exposing (Device, Element, circle, column, empty, el, image, link, text, row, viewport, when, whenJust)
import Element.Attributes exposing (center, height, padding, paddingBottom, paddingLeft, paddingRight, paddingXY, percent, px, spacing, target, toAttr, vary, verticalCenter, width)
import Element.Events exposing (onClick)
import Helpers exposing (cohortText, getCohortAnim)
import Html exposing (Html)
import List.Extra exposing (greedyGroupsOf)
import Model exposing (Model, Campus, Cohort, CohortAnim, GithubImage(..), Student, Msg(..))
import Styling exposing (styling, Styles(..), Variations(..))


view : Model -> Html Msg
view { campuses, selectedCampus, selectedCohort, cohortAnims, githubImages, device } =
    let
        body =
            case ( selectedCampus, selectedCohort ) of
                ( Just campus, Just cohort ) ->
                    let
                        anim =
                            getCohortAnim cohort cohortAnims
                    in
                        [ viewCampus device campus
                        , viewSingleCohort device anim githubImages cohort
                        ]

                ( Just campus, Nothing ) ->
                    let
                        cohortsWithAnimations : List ( CohortAnim, Cohort )
                        cohortsWithAnimations =
                            campus.cohorts
                                |> List.map
                                    (\cohort ->
                                        let
                                            anim =
                                                getCohortAnim cohort cohortAnims
                                        in
                                            ( anim, cohort )
                                    )
                    in
                        [ viewCampus device campus, viewCohorts device cohortsWithAnimations ]

                ( Nothing, Nothing ) ->
                    [ viewCampuses device campuses ]

                ( Nothing, Just _ ) ->
                    [ viewCampuses device campuses ]
    in
        viewport styling <|
            column None
                []
                [ header device
                , column None
                    [ center
                    , width <| percent 100
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


viewCampus : Device -> Campus -> Element Styles Variations Msg
viewCampus device campus =
    el CampusText
        [ center
        , verticalCenter
        , onClick <| SelectCampus campus
        , vary Mobile device.phone
        ]
    <|
        text <|
            String.toUpper campus.name


viewCampuses : Device -> List Campus -> Element Styles Variations Msg
viewCampuses device =
    List.map (viewCampus device)
        >> column None
            [ center, width <| percent 100, verticalCenter ]


viewCohorts : Device -> List ( CohortAnim, Cohort ) -> Element Styles variation Msg
viewCohorts device cohortsWithAnimations =
    let
        content =
            cohortsWithAnimations
                |> List.map (uncurry (cohortCircle device))
                |> greedyGroupsOf 3
                |> List.map (row None [ spacing 5, padding 5 ])
    in
        column None [ center, paddingBottom 15 ] content


viewSingleCohort : Device -> CohortAnim -> Dict String GithubImage -> Cohort -> Element Styles variation Msg
viewSingleCohort device anim githubImages cohort =
    column None
        [ padding 5 ]
        [ cohortCircle device anim cohort
        , viewStudents device cohort.students githubImages
        ]


viewStudents : Device -> List Student -> Dict String GithubImage -> Element Styles variation Msg
viewStudents device students githubImages =
    column None
        [ center ]
        (students
            |> List.map
                (\{ firstName, github } ->
                    let
                        imgSrc =
                            github
                                |> Maybe.andThen (flip Dict.get githubImages)
                                |> Maybe.map
                                    (\res ->
                                        case res of
                                            GithubImage img ->
                                                img

                                            Loading ->
                                                "/spin.svg"

                                            Failed ->
                                                "/logo.png"
                                    )
                                |> Maybe.withDefault "/logo.png"
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
                )
            |> greedyGroupsOf 4
            |> List.map (row None [])
        )


cohortCircle : Device -> CohortAnim -> Cohort -> Element Styles v Msg
cohortCircle device ( frontAnim, backAnim ) cohort =
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
            [ onClick <| SelectCohort cohort
            , height <| px size
            , width <| px size
            , center
            ]
            empty
            |> Element.within [ side frontAnim Num <| toString cohort.num, side backAnim None datesText ]


renderAnim : Animation.State -> List (Element.Attribute variation Msg) -> List (Element.Attribute variation Msg)
renderAnim animStyle otherAttrs =
    animStyle
        |> Animation.render
        |> List.map toAttr
        |> (++) otherAttrs
