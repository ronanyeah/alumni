module Styling exposing (styling, Styles(..), Variations(..))

import Style exposing (StyleSheet, style, stylesheet, variation)
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
    | Num
    | Red
    | StudentImg
    | Words


type Variations
    = Mobile


facFont : Style.Property class variation
facFont =
    Font.typeface [ "UG" ]


styling : StyleSheet Styles Variations
styling =
    stylesheet
        [ style Blue [ facFont, Color.background blue, Style.cursor "crosshair" ]
        , style CampusImage [ Bg.image "url(/valley.jpg)", Style.cursor "pointer" ]
        , style CampusRow []
        , style CampusText
            [ Color.background <| rgb 235 235 235
            , Bg.image "url(https://foundersandcoders.com/assets/fac-teamwork.jpg)"
            , Font.size 80
            , facFont
            , Style.cursor "pointer"
            , Style.prop "-webkit-background-clip" "text"
            , Style.prop "-webkit-text-fill-color" "transparent"
            , variation Mobile [ Font.size 30 ]
            ]
        , style CampusCircle
            [ facFont
            , Color.background <| rgb 235 235 235
            , Style.cursor "pointer"
            ]
        , style HeaderText [ Font.typeface [ "UGmed" ], Color.text black ]
        , style Header []
        , style Image []
        , style None []
        , style Num [ Font.size 80 ]
        , style Red [ facFont, Color.background red, Style.cursor "crosshair" ]
        , style StudentImg [ Border.rounded 25 ]
        ]
