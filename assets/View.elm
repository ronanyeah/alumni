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
view model =
    viewport styling <|
        column None
            []
            [ header model.device
            , viewCampuses model
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


viewCampuses : Model -> Element Styles Variations Msg
viewCampuses { campuses, selectedCampus, selectedCohort, cohortAnims, githubImages, device } =
    column None
        [ center, width <| percent 100, verticalCenter ]
        (campuses
            |> List.foldl
                (\campus arr ->
                    let
                        viewCampus =
                            el CampusText
                                [ center
                                , verticalCenter
                                , onClick <| SelectCampus campus
                                , vary Mobile device.phone
                                ]
                            <|
                                text <|
                                    String.toUpper campus.name

                        default =
                            arr ++ [ viewCampus ]
                    in
                        case ( selectedCampus, selectedCohort ) of
                            ( Just c, Just numCohort ) ->
                                if c == campus then
                                    let
                                        anim =
                                            getCohortAnim numCohort cohortAnims
                                    in
                                        arr
                                            ++ [ viewCampus
                                               , viewSingleCohort device anim githubImages numCohort
                                               ]
                                else
                                    default

                            ( Just c, Nothing ) ->
                                if c == campus then
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
                                        arr ++ [ viewCampus, viewCohorts device cohortsWithAnimations ]
                                else
                                    default

                            ( Nothing, Nothing ) ->
                                default

                            ( Nothing, Just _ ) ->
                                default
                )
                []
        )


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
            circle 100
                CampusCircle
                (renderAnim anim [ center, height <| px size, width <| px size, verticalCenter ])
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
