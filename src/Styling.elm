module Styling exposing (Styles(..), Variations(..), styling)

import Color exposing (rgb)
import Style exposing (StyleSheet, style, styleSheet, variation)
import Style.Border as Border
import Style.Color exposing (background, text)
import Style.Font as Font
import Style.Shadow as Shadow


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
    Font.typeface [ Font.font "UG" ]


grey : Color.Color
grey =
    rgb 235 235 235


darkGrey : Color.Color
darkGrey =
    rgb 113 123 127


styling : StyleSheet Styles Variations
styling =
    styleSheet
        [ style CampusCircle
            [ facFont
            , background grey
            , Style.cursor "pointer"
            , Shadow.simple
            ]
        , style CampusText
            [ Font.size 80
            , facFont
            , Style.cursor "pointer"
            , text darkGrey
            , variation Mobile [ Font.size 30 ]
            ]
        , style CohortDates
            [ Font.size 20, variation Mobile [ Font.size 15 ] ]
        , style CohortNum [ Font.size 80, variation Mobile [ Font.size 50 ] ]
        , style None []
        , style StudentImg [ Border.rounded 25, Shadow.simple ]
        , style Text [ Font.typeface [ Font.font "UGmed" ], text Color.black ]
        ]
