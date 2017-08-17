module Model exposing (Campus, Cohort, CohortAnims, Student, Campuses, Model, Msg(..))

import Animation
import Date
import Dict exposing (Dict)
import GraphQL.Client.Http as Gr


type alias Model =
    { campuses : List Campus
    , selectedCampus : String
    , selectedCohort : String
    , cohortAnims : CohortAnims
    }


type alias CohortAnims =
    Dict String ( Animation.State, Animation.State )


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
    , github : String
    }


type alias Campuses =
    { allCampuses : List Campus
    }


type Msg
    = Animate Animation.Msg
    | Flip String
    | FlipBack String
    | CbCampuses (Result Gr.Error Campuses)
    | SelectCampus String
    | SelectCohort String
