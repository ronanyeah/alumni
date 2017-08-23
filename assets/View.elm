module View exposing (view)

import Animation
import Dict exposing (Dict)
import Element exposing (Element, circle, column, empty, el, image, link, text, row, viewport, when, whenJust)
import Element.Attributes exposing (center, height, padding, paddingBottom, paddingLeft, paddingRight, paddingXY, percent, px, spacing, target, toAttr, verticalCenter, width)
import Element.Events exposing (onClick)
import Fixtures exposing (frontInit, backInit)
import Helpers exposing (cohortText, sortByStartDate)
import Html exposing (Html)
import List.Extra exposing (greedyGroupsOf)
import Model exposing (Model, Campus, Cohort, CohortAnims, GithubImage(..), Student, Msg(..))
import Styling exposing (styling, Styles(..))


view : Model -> Html Msg
view { campuses, selectedCampus, selectedCohort, cohortAnims, githubImages } =
    viewport styling <|
        column None
            []
            [ header
            , viewCampuses campuses selectedCohort selectedCampus cohortAnims githubImages
            ]


header : Element Styles variation Msg
header =
    (link "https://foundersandcoders.com/" <|
        el None [ target "_blank", paddingXY 0 15, center, verticalCenter ] <|
            image "/logo.png" Image [ height (px 50) ] empty
    )
        |> Element.onRight [ el HeaderText [ paddingLeft 15, verticalCenter ] <| text "Alumni" ]
        |> Element.onLeft [ el HeaderText [ paddingRight 15, verticalCenter, width <| px 160 ] <| text "Founders & Coders" ]


viewCampuses : List Campus -> String -> String -> CohortAnims -> Dict String GithubImage -> Element Styles variation Msg
viewCampuses campuses selectedCohort selectedCampus cohortAnims githubImages =
    column None
        [ center, width <| percent 100, verticalCenter ]
        (campuses
            |> List.foldl
                (\{ id, name, cohorts } arr ->
                    let
                        numberedCohorts : List ( Int, Cohort )
                        numberedCohorts =
                            cohorts
                                |> sortByStartDate
                                |> List.indexedMap (,)

                        dropdown =
                            if selectedCohort == "" then
                                viewCohorts numberedCohorts cohortAnims
                            else
                                numberedCohorts
                                    |> List.filter (Tuple.second >> (.id >> (==) selectedCohort))
                                    |> List.head
                                    |> flip whenJust (viewSingleCohort cohortAnims githubImages)

                        campus =
                            el Words
                                [ center
                                , verticalCenter
                                , onClick <| SelectCampus id
                                ]
                            <|
                                text <|
                                    String.toUpper name
                    in
                        arr
                            ++ [ campus
                               , when (selectedCampus == id) dropdown
                               ]
                )
                []
        )


viewCohorts : List ( Int, Cohort ) -> CohortAnims -> Element Styles variation Msg
viewCohorts cohorts cohortAnims =
    let
        content =
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
                |> List.map (row None [ spacing 5, padding 5 ])
    in
        column None [ center, paddingBottom 15 ] content


viewSingleCohort : CohortAnims -> Dict String GithubImage -> ( Int, Cohort ) -> Element Styles variation Msg
viewSingleCohort cohortAnims githubImages ( i, { id, startDate, endDate, students } ) =
    let
        anims =
            cohortAnims
                |> Dict.get id
                |> Maybe.withDefault ( frontInit, backInit )
    in
        column None
            []
            [ cohortCircle anims (cohortText startDate endDate) i id
            , viewStudents students githubImages
            ]


viewStudents : List Student -> Dict String GithubImage -> Element Styles variation Msg
viewStudents students githubImages =
    column None
        [ center, padding 20 ]
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
            [ onClick <| SelectCohort id
            , height <| px 200
            , width <| px 200
            , center
            ]
            empty
            |> Element.within [ front, back ]


renderAnim : Animation.State -> List (Element.Attribute variation Msg) -> List (Element.Attribute variation Msg)
renderAnim animStyle otherAttrs =
    animStyle
        |> Animation.render
        |> List.map toAttr
        |> (++) otherAttrs
