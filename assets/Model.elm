module Model exposing (Campus, Cohort, Student, AllData, CohortForm, StudentForm, Model, Msg(..))

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
    , cohortForm : Maybe CohortForm
    , studentForm : Maybe StudentForm
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


type Msg
    = Animate Animation.Msg
    | Flip String
    | FlipBack String
    | CbAllData (Result Gr.Error AllData)
    | CbCreateCohort (Result Gr.Error Cohort)
    | CbCreateStudent (Result Gr.Error Student)
    | CohortFormCancel
    | CohortFormEnable
    | CohortFormSetCampus String
    | CohortFormSetEndDate String
    | CohortFormSetStartDate String
    | CohortFormSubmit
    | SelectCampus String
    | SelectCohort String
    | StudentFormCancel
    | StudentFormEnable
    | StudentFormSetCohort String
    | StudentFormSetFirstName String
    | StudentFormSetLastName String
    | StudentFormSetGithub String
    | StudentFormSubmit
