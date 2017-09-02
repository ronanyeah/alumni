module Styling exposing (styling, Styles(..), Variations(..))

import Style exposing (StyleSheet, style, stylesheet, variation)
import Style.Font as Font
import Style.Color exposing (background, text)
import Style.Border as Border
import Style.Shadow as Shadow
import Color exposing (rgb)


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


grey : Color.Color
grey =
    rgb 235 235 235


darkGrey : Color.Color
darkGrey =
    rgb 113 123 127


styling : StyleSheet Styles Variations
styling =
    stylesheet
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
        , style Text [ Font.typeface [ "UGmed" ], text Color.black ]
        ]
