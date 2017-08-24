module Model exposing (Campus, Cohort, CohortAnims, GithubImage(..), Student, Campuses, Model, Msg(..))

import Animation
import Date
import Dict exposing (Dict)
import Element
import Http
import GraphQL.Client.Http as Gr
import Window


type GithubImage
    = Loading
    | Failed
    | GithubImage String


type alias Model =
    { campuses : List Campus
    , selectedCampus : Maybe Campus
    , selectedCohort : Maybe ( Int, Cohort )
    , cohortAnims : CohortAnims
    , githubImages : Dict String GithubImage
    , githubAuth : ( String, String )
    , device : Element.Device
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
    , github : Maybe String
    }


type alias Campuses =
    { allCampuses : List Campus
    }


type Msg
    = Animate Animation.Msg
    | CbGithubImage String (Result Http.Error String)
    | CbCampuses (Result Gr.Error Campuses)
    | Resize Window.Size
    | SelectCampus Campus
    | SelectCohort ( Int, Cohort )
