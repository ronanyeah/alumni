module Fixtures exposing (..)

import Animation exposing (deg)
import Dict
import Model exposing (Model, State(NothingSelected))


emptyModel : Model
emptyModel =
    { campuses = []
    , state = NothingSelected
    , cohortAnims = Dict.empty
    , githubImages = Dict.empty
    , githubToken = ""
    , device =
        { width = 0
        , height = 0
        , phone = False
        , tablet = False
        , desktop = False
        , bigDesktop = False
        , portrait = False
        }
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
