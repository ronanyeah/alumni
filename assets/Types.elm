module Types exposing (Campus, Cohort, Student, AllData, NewCohort)

import Date


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


type alias NewCohort =
    { startDate : Date.Date
    , endDate : Date.Date
    , campus : Maybe Campus
    }
