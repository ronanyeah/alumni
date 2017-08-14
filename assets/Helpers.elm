module Helpers exposing (..)

import Date exposing (Date)
import Date.Extra


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
