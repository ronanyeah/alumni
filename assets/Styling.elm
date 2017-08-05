module Styling exposing (..)

import Style exposing (StyleSheet)
import Style.Background as Bg
import Style.Font as Font
import Style.Color as Color
import Color exposing (..)


type Styles
    = CampusImage
    | CampusRow
    | CampusText
    | Header
    | HeaderText
    | Image
    | None


facFont : Style.Property class variation
facFont =
    Font.typeface [ "UGmed" ]


style : StyleSheet Styles variation
style =
    Style.stylesheet
        [ Style.style CampusImage [ Bg.image "url(/valley.jpg)", Style.cursor "pointer" ]
        , Style.style CampusRow []
        , Style.style CampusText [ facFont, Color.background white ]
        , Style.style HeaderText [ facFont ]
        , Style.style Header []
        , Style.style Image []
        , Style.style None []
        ]
