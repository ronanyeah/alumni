module Fixtures exposing (..)

import Animation exposing (deg)
import Dict
import Model exposing (Model)


emptyModel : Model
emptyModel =
    { campuses = []
    , selectedCampus = ""
    , selectedCohort = ""
    , cohortAnims = Dict.empty
    }


frontInit : Animation.State
frontInit =
    Animation.style
        [ Animation.rotate3d (deg 0) (deg 0) (deg 0)
        , Animation.opacity 1
        ]


backInit : Animation.State
backInit =
    Animation.style
        [ Animation.rotate3d (deg 0) (deg 180) (deg 0)
        , Animation.opacity 0
        ]
