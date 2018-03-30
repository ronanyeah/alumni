module View exposing (view)

import Color exposing (Color, rgb)
import Dict exposing (Dict)
import Element exposing (Attribute, Device, Element, centerX, centerY, column, el, empty, fill, height, image, layout, newTabLink, padding, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Helpers exposing (cohortText, getCohortAnim, renderAnim, whenJust)
import Html exposing (Html)
import List.Extra exposing (greedyGroupsOf)
import Model exposing (Campus, Cohort, CohortAnim, GithubImage(..), Model, Msg(..), State(..), Student)


font : Attribute msg
font =
    Font.family
        [ Font.external
            { name = "UG"
            , url = "/fonts.css"
            }
        ]


mediumFont : Attribute msg
mediumFont =
    Font.family
        [ Font.external
            { name = "UGmed"
            , url = "/fonts.css"
            }
        ]


grey : Color
grey =
    rgb 235 235 235


darkGrey : Color
darkGrey =
    rgb 113 123 127


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
                    , el [ padding 5, centerX ] <| viewCohort device anim cohort DeselectCohort
                    , viewStudents device githubImages cohort.students
                    ]
    in
    layout [] <|
        column
            []
            [ header device
            , column
                [ centerX
                , centerY
                ]
                body
            ]


header : Device -> Element Msg
header { phone } =
    let
        txts =
            if phone then
                []
            else
                [ Element.onRight <|
                    el
                        [ padding 15
                        , centerY
                        , mediumFont
                        , Font.color Color.black
                        ]
                    <|
                        text "Alumni"
                , Element.onLeft <|
                    el
                        [ padding 15
                        , centerY
                        , mediumFont
                        , Font.color Color.black
                        ]
                    <|
                        text "Founders & Coders"
                ]
    in
    newTabLink ([ centerX, padding 20 ] ++ txts)
        { url = "https://foundersandcoders.com/"
        , label =
            image [ height <| px 50 ]
                { src = "/logo.png"
                , description = "FAC Logo"
                }
        }


viewCampuses : Device -> List Campus -> Element Msg
viewCampuses device =
    List.map
        (\campus ->
            viewCampus device campus (SelectCampus campus)
        )
        >> column
            [ centerX
            , width fill
            , centerY
            ]


viewCampus : Device -> Campus -> Msg -> Element Msg
viewCampus device campus clickMsg =
    el
        [ centerX
        , centerY
        , onClick clickMsg
        , if device.phone then
            Font.size 30
          else
            Font.size 80
        , font
        , Element.pointer
        , Font.color darkGrey
        ]
    <|
        text <|
            String.toUpper campus.name


viewCohorts : Device -> Dict String CohortAnim -> List Cohort -> Element Msg
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
                |> List.map (row [ spacing 5, padding 5 ])
    in
    column [ centerX, padding 15 ] content


viewCohort : Device -> CohortAnim -> Cohort -> Msg -> Element Msg
viewCohort device ( frontAnim, backAnim ) cohort clickMsg =
    let
        size =
            if device.phone then
                device.width
                    |> toFloat
                    |> (*) 0.3
                    |> round
            else
                200

        attrs =
            [ font
            , Background.color grey
            , Element.pointer
            , Border.rounded <| size // 2
            , width <| px size
            , height <| px size
            , Border.shadow
                { offset = ( 0, 0 )
                , blur = 10
                , size = 3
                , color = Color.grey
                }
            , centerX
            , centerY
            ]

        front =
            el
                (renderAnim frontAnim attrs)
            <|
                el
                    [ if device.phone then
                        Font.size 50
                      else
                        Font.size 80
                    , centerX
                    , centerY
                    ]
                <|
                    text <|
                        toString cohort.num

        back =
            el
                (renderAnim backAnim attrs)
            <|
                el
                    [ if device.phone then
                        Font.size 15
                      else
                        Font.size 20
                    , centerX
                    , centerY
                    ]
                <|
                    text <|
                        cohortText cohort.startDate cohort.endDate
    in
    el
        [ onClick clickMsg
        , height <| px size
        , width <| px size
        , centerX
        , padding 5
        , Element.inFront front
        , Element.behind back
        ]
        empty


viewStudents : Device -> Dict String GithubImage -> List Student -> Element Msg
viewStudents device githubImages students =
    el [ centerX ] <|
        column
            [ padding 20, spacing 20 ]
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
                |> List.map (row [ spacing 10 ] >> el [ centerX ])
            )


viewStudent : Device -> GithubImage -> Student -> Element Msg
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
                    |> px
                    |> width
            else
                width <| px 90
    in
    column
        [ centerY, colWidth, centerX, spacing 10 ]
        [ image
            [ width <| px 50
            , height <| px 50
            , Border.rounded 25
            , centerX
            , Border.shadow
                { offset = ( 0, 0 )
                , blur = 10
                , size = 3
                , color = Color.grey
                }
            ]
            { src = imgSrc, description = "Student Image" }
        , el
            [ mediumFont
            , Font.color Color.black
            , padding 10
            , centerX
            ]
          <|
            text firstName
        , github
            |> whenJust
                (\username ->
                    newTabLink [ centerX ]
                        { url = "https://github.com/" ++ username
                        , label =
                            image []
                                { src = "/gh.svg"
                                , description = "Github Link"
                                }
                        }
                )
        ]
