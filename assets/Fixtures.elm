module Fixtures exposing (..)

import Animation exposing (deg)
import Dict
import Model exposing (Model)


emptyModel : Model
emptyModel =
    { campuses = []
    , selectedCampus = Nothing
    , selectedCohort = Nothing
    , cohortAnims = Dict.empty
    , githubImages = Dict.empty
    , githubAuth = ( "", "" )
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
