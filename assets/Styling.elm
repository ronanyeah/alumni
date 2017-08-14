module Styling exposing (styling, Styles(..))

import Style exposing (StyleSheet, style, stylesheet)
import Style.Background as Bg
import Style.Font as Font
import Style.Color as Color
import Style.Border as Border
import Color exposing (..)


type Styles
    = Anim
    | Blue
    | CampusCircle
    | CampusImage
    | CampusRow
    | CampusText
    | Header
    | HeaderText
    | Image
    | None
    | Red
    | StudentImg
    | Words


facFont : Style.Property class variation
facFont =
    Font.typeface [ "UG" ]


styling : StyleSheet Styles variation
styling =
    stylesheet
        [ style Blue [ facFont, Color.background blue, Style.cursor "crosshair" ]
        , style CampusImage [ Bg.image "url(/valley.jpg)", Style.cursor "pointer" ]
        , style CampusRow []
        , style CampusText [ facFont, Color.background white ]
        , style CampusCircle
            [ facFont
            , Color.background <| rgb 235 235 235
            , Style.cursor "pointer"
            ]
        , style HeaderText [ Font.typeface [ "UGmed" ] ]
        , style Header []
        , style Image []
        , style None []
        , style Red [ facFont, Color.background red, Style.cursor "crosshair" ]
        , style StudentImg [ Border.rounded 25 ]
        , style Words
            [ Bg.image "url(https://foundersandcoders.com/assets/fac-teamwork.jpg)"
            , Color.background blue
            , Font.size 80
            , facFont
            , Style.cursor "pointer"
            , Style.prop "-webkit-background-clip" "text"
            , Style.prop "-webkit-text-fill-color" "transparent"
            ]
        ]
