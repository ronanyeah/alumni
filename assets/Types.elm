module Types exposing (Campus, Cohort, Student, NewCohort)

import Date


type alias Campus =
    { id : String
    , name : String
    , cohorts : List Cohort
    }


type alias Cohort =
    { id : String
    , startDate : Date.Date
    , endDate : Date.Date
    , students : List Student
    }


type alias Student =
    { id : String
    , firstName : String
    , lastName : String
    , github : String
    }


type alias NewCohort =
    { startDate : Date.Date
    , endDate : Date.Date
    , campus : Maybe Campus
    }
