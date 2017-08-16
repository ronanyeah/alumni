module Model exposing (Campus, Cohort, Student, AllData, Model, Msg(..))

import Animation
import Date
import Dict exposing (Dict)
import GraphQL.Client.Http as Gr


type alias Model =
    { campuses : Dict String Campus
    , cohorts : Dict String Cohort
    , students : Dict String Student
    , selectedCampus : String
    , selectedCohort : String
    , cohortHover : Dict String ( Animation.State, Animation.State )
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
    , github : String
    }


type alias AllData =
    { campuses : List Campus
    , cohorts : List Cohort
    , students : List Student
    }


type Msg
    = Animate Animation.Msg
    | Flip String
    | FlipBack String
    | CbAllData (Result Gr.Error AllData)
    | SelectCampus String
    | SelectCohort String
