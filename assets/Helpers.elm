module Helpers exposing (..)

import Animation
import Element
import Element.Attributes
import Date exposing (Date)
import Dict exposing (Dict)
import Fixtures exposing (frontInit, backInit)
import Model exposing (Cohort, CohortAnim, GithubImage(..), Msg(..))


log : String -> a -> Cmd msg
log l v =
    let
        _ =
            Debug.log l v
    in
        Cmd.none


dateParse : String -> Date.Date
dateParse =
    Date.fromString
        >> Result.withDefault (Date.fromTime 0)


sortByStartDate : List { a | startDate : Date } -> List { a | startDate : Date }
sortByStartDate =
    List.sortBy (.startDate >> Date.toTime)


cohortText : Date.Date -> Date.Date -> String
cohortText start end =
    let
        render date =
            (date |> Date.month |> toString) ++ " " ++ (date |> Date.year |> toString)
    in
        render start ++ " / " ++ render end


getCohortAnim : Cohort -> Dict String CohortAnim -> CohortAnim
getCohortAnim { id } =
    Dict.get id
        >> Maybe.withDefault ( frontInit, backInit )


renderAnim : Animation.State -> List (Element.Attribute variation Msg) -> List (Element.Attribute variation Msg)
renderAnim animStyle otherAttrs =
    animStyle
        |> Animation.render
        |> List.map Element.Attributes.toAttr
        |> (++) otherAttrs
