module Fixtures exposing (..)

import Date
import Dict
import Types exposing (CohortForm, StudentForm, Model)


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
    }
