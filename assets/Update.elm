module Update exposing (update)

import Animation exposing (deg)
import Dict
import Fixtures exposing (frontInit, backInit)
import Helpers exposing (log, dictById)
import Model exposing (Model, Msg(..))
import Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Flip k ->
            let
                ( front, back ) =
                    model.cohortHover
                        |> Dict.get k
                        |> Maybe.withDefault ( frontInit, backInit )

                frontAnim =
                    Animation.interrupt
                        [ Animation.toWith
                            (Animation.easing
                                { duration = 0.2 * Time.second
                                , ease = identity
                                }
                            )
                            [ Animation.rotate3d (deg 0) (deg 180) (deg 0)
                            , Animation.opacity 0
                            ]
                        ]
                        front

                backAnim =
                    Animation.interrupt
                        [ Animation.toWith
                            (Animation.easing
                                { duration = 0.2 * Time.second
                                , ease = identity
                                }
                            )
                            [ Animation.rotate3d (deg 0) (deg 0) (deg 0)
                            , Animation.opacity 1
                            ]
                        ]
                        back
            in
                ( { model
                    | cohortHover =
                        model.cohortHover
                            |> Dict.insert k ( frontAnim, backAnim )
                  }
                , Cmd.none
                )

        FlipBack k ->
            let
                ( front, back ) =
                    model.cohortHover
                        |> Dict.get k
                        |> Maybe.withDefault ( frontInit, backInit )

                frontAnim =
                    Animation.interrupt
                        [ Animation.toWith
                            (Animation.easing
                                { duration = 0.2 * Time.second
                                , ease = identity
                                }
                            )
                            [ Animation.rotate3d (deg 0) (deg 0) (deg 0)
                            , Animation.opacity 1
                            ]
                        ]
                        front

                backAnim =
                    Animation.interrupt
                        [ Animation.toWith
                            (Animation.easing
                                { duration = 0.2 * Time.second
                                , ease = identity
                                }
                            )
                            [ Animation.rotate3d (deg 0) (deg 180) (deg 0)
                            , Animation.opacity 0
                            ]
                        ]
                        back
            in
                ( { model
                    | cohortHover =
                        model.cohortHover
                            |> Dict.insert k ( frontAnim, backAnim )
                  }
                , Cmd.none
                )

        Animate animMsg ->
            { model
                | cohortHover =
                    Dict.map
                        (\_ ( front, back ) ->
                            ( Animation.update animMsg front, Animation.update animMsg back )
                        )
                        model.cohortHover
            }
                ! []

        CbAllData res ->
            case res of
                Ok { campuses, cohorts, students } ->
                    { model
                        | campuses = dictById campuses
                        , cohorts = dictById cohorts
                        , students = dictById students
                    }
                        ! []

                Err err ->
                    model ! [ log "err" err ]

        SelectCampus campusId ->
            let
                selectedCampus =
                    if campusId == model.selectedCampus then
                        ""
                    else
                        campusId
            in
                { model | selectedCampus = selectedCampus, selectedCohort = "" } ! []

        SelectCohort id ->
            let
                selectedCohort =
                    if id == model.selectedCohort then
                        ""
                    else
                        id
            in
                { model | selectedCohort = selectedCohort } ! []
