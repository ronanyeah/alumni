module Fixtures exposing (..)

import Animation exposing (deg)
import Date
import Dict
import Model exposing (CohortForm, StudentForm, Model)


emptyNewCohort : CohortForm
emptyNewCohort =
    { startDate = Date.fromTime 1483228800000
    , endDate = Date.fromTime 1488326400000
    , campusId = ""
    }


emptyStudentForm : StudentForm
emptyStudentForm =
    { cohortId = ""
    , firstName = ""
    , lastName = ""
    , github = ""
    }


emptyModel : Model
emptyModel =
    { campuses = Dict.empty
    , cohorts = Dict.empty
    , students = Dict.empty
    , selectedCampus = ""
    , selectedCohort = ""
    , cohortForm = Nothing
    , studentForm = Nothing
    , cohortHover = Dict.empty
    }


frontInit : Animation.State
frontInit =
    (Animation.style
        [ Animation.rotate3d (deg 0) (deg 0) (deg 0)
        , Animation.opacity 1
        ]
    )


backInit : Animation.State
backInit =
    (Animation.style
        [ Animation.rotate3d (deg 0) (deg 180) (deg 0)
        , Animation.opacity 0
        ]
    )
