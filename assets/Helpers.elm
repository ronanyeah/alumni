module Helpers exposing (..)

import Date exposing (Date)


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
        render start ++ " to " ++ render end
