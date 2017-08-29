module Model exposing (..)

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


type State
    = NothingSelected
    | CampusSelected Campus
    | CohortSelected Campus Cohort


type alias CohortAnim =
    ( Animation.State, Animation.State )


type alias Model =
    { campuses : List Campus
    , state : State
    , cohortAnims : Dict String CohortAnim
    , githubImages : Dict String GithubImage
    , githubAuth : ( String, String )
    , device : Element.Device
    }


type alias CampusWithoutNum =
    { id : String
    , name : String
    , cohorts : List CohortWithoutNum
    }


type alias Campus =
    { id : String
    , name : String
    , cohorts : List Cohort
    }


type alias CohortWithoutNum =
    { id : String
    , startDate : Date.Date
    , endDate : Date.Date
    , students : List Student
    }


type alias Cohort =
    { id : String
    , startDate : Date.Date
    , endDate : Date.Date
    , students : List Student
    , num : Int
    }


type alias Student =
    { id : String
    , firstName : String
    , github : Maybe String
    }


type Msg
    = Animate Animation.Msg
    | CbGithubImage String (Result Http.Error String)
    | CbCampuses (Result Gr.Error (List CampusWithoutNum))
    | Resize Window.Size
    | SelectCampus Campus
    | DeselectCampus
    | SelectCohort Cohort
    | DeselectCohort
