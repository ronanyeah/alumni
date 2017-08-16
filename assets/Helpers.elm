module Helpers exposing (..)

import Date exposing (Date)
import Date.Extra
import Dict exposing (Dict)


formatDate : Date -> String
formatDate =
    Date.Extra.toFormattedString "yyyy-MM-dd"


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


dictById : List { x | id : String } -> Dict String { x | id : String }
dictById =
    List.map (\x -> ( x.id, x )) >> Dict.fromList


dateFromString : String -> Date.Date
dateFromString =
    Date.fromString >> Result.withDefault (Date.fromTime 1483228800000)
