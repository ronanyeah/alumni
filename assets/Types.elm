module Types exposing (Campus, Cohort, Student)

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
