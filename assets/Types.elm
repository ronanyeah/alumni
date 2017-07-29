module Types exposing (Campus, Cohort, Student, AllData, CohortForm, StudentForm, Model)

import Date
import Dict exposing (Dict)


type alias Model =
    { campuses : Dict String Campus
    , cohorts : Dict String Cohort
    , students : Dict String Student
    , selectedCampus : String
    , selectedCohort : String
    , cohortForm : Maybe CohortForm
    , studentForm : Maybe StudentForm
    }


type alias Campus =
    { id : String
    , name : String
    }


type alias Cohort =
    { id : String
    , campusId : String
    , startDate : Date.Date
    , endDate : Date.Date
    }


type alias Student =
    { id : String
    , cohortId : String
    , firstName : String
    , lastName : String
    , github : String
    }


type alias AllData =
    { campuses : List Campus
    , cohorts : List Cohort
    , students : List Student
    }


type alias CohortForm =
    { startDate : Date.Date
    , endDate : Date.Date
    , campusId : String
    }


type alias StudentForm =
    { cohortId : String
    , firstName : String
    , lastName : String
    , github : String
    }
