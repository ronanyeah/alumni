module Data exposing (fetch)

import Helpers exposing (dateParse)
import Model exposing (Cohort, Campus, Student, Campuses)
import GraphQL.Client.Http as Gr
import GraphQL.Request.Builder as G
import Task exposing (Task)


fetch : String -> Task Gr.Error Campuses
fetch url =
    Gr.sendQuery url queryAllData


queryAllData : G.Request G.Query Campuses
queryAllData =
    let
        query : G.Document G.Query Campuses vars
        query =
            G.object Campuses
                |> G.with (G.field "allCampuses" [] (G.list campus))
                |> G.queryDocument
    in
        G.request () query



-- GRAPHQL TYPES


campus : G.ValueSpec G.NonNull G.ObjectType Campus vars
campus =
    G.object Campus
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "name" [] G.string)
        |> G.with (G.field "cohorts" [] (G.list cohort))


cohort : G.ValueSpec G.NonNull G.ObjectType Cohort vars
cohort =
    G.object Cohort
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "startDate" [] (G.map dateParse G.string))
        |> G.with (G.field "endDate" [] (G.map dateParse G.string))
        |> G.with (G.field "students" [] (G.list student))


student : G.ValueSpec G.NonNull G.ObjectType Student vars
student =
    G.object Student
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "firstName" [] G.string)
        |> G.with (G.field "github" [] G.string)
