module Styling exposing (styling, Styles(..), Variations(..))

import Style exposing (StyleSheet, style, stylesheet, variation)
import Style.Background as Bg
import Style.Font as Font
import Style.Color as Color
import Style.Border as Border
import Style.Shadow as Shadow
import Color exposing (..)


type Styles
    = CampusCircle
    | CampusText
    | CohortNum
    | CohortDates
    | None
    | StudentImg
    | Text


type Variations
    = Mobile


facFont : Style.Property class variation
facFont =
    Font.typeface [ "UG" ]


styling : StyleSheet Styles Variations
styling =
    stylesheet
        [ style CampusCircle
            [ facFont
            , Color.background <| rgb 235 235 235
            , Style.cursor "pointer"
            , Shadow.simple
            ]
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
        , style CohortDates
            [ Font.size 20, variation Mobile [ Font.size 10 ] ]
        , style CohortNum [ Font.size 80 ]
        , style None []
        , style StudentImg [ Border.rounded 25, Shadow.simple ]
        , style Text [ Font.typeface [ "UGmed" ], Color.text black ]
        ]
