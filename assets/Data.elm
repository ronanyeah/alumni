module Data exposing (fetch)

import Helpers exposing (dateParse)
import Model exposing (AllCampuses, CohortWithoutNum, CampusWithoutNum, Student)
import GraphQL.Client.Http as Gr
import GraphQL.Request.Builder as G
import Task exposing (Task)


fetch : String -> Task Gr.Error AllCampuses
fetch url =
    Gr.sendQuery url queryAllData


queryAllData : G.Request G.Query AllCampuses
queryAllData =
    let
        query : G.Document G.Query AllCampuses vars
        query =
            G.object AllCampuses
                |> G.with (G.field "allCampuses" [] (G.list campus))
                |> G.queryDocument
    in
        G.request () query



-- GRAPHQL TYPES


campus : G.ValueSpec G.NonNull G.ObjectType CampusWithoutNum vars
campus =
    G.object CampusWithoutNum
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "name" [] G.string)
        |> G.with (G.field "cohorts" [] (G.list cohort))


cohort : G.ValueSpec G.NonNull G.ObjectType CohortWithoutNum vars
cohort =
    G.object CohortWithoutNum
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "startDate" [] (G.map dateParse G.string))
        |> G.with (G.field "endDate" [] (G.map dateParse G.string))
        |> G.with (G.field "students" [] (G.list student))


student : G.ValueSpec G.NonNull G.ObjectType Student vars
student =
    G.object Student
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "firstName" [] G.string)
        |> G.with (G.field "github" [] <| G.nullable G.string)
