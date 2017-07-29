module Helpers exposing (..)

import Date exposing (Date)
import Date.Extra


formatDate : Date -> String
formatDate =
    Date.Extra.toFormattedString "yyyy-MM-dd"
