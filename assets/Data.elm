module Data exposing (queryAllData)

import Helpers exposing (dateParse)
import Model exposing (Cohort, Campus, Student, AllData)
import GraphQL.Request.Builder as G


queryAllData : G.Request G.Query AllData
queryAllData =
    let
        query : G.Document G.Query AllData vars
        query =
            G.object AllData
                |> G.with (G.field "campuses" [] (G.list campus))
                |> G.with (G.field "cohorts" [] (G.list cohort))
                |> G.with (G.field "students" [] (G.list student))
                |> G.queryDocument
    in
        G.request () query



-- GRAPHQL TYPES


campus : G.ValueSpec G.NonNull G.ObjectType Campus vars
campus =
    G.object Campus
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "name" [] G.string)


cohort : G.ValueSpec G.NonNull G.ObjectType Cohort vars
cohort =
    G.object Cohort
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "campusId" [] G.string)
        |> G.with (G.field "startDate" [] (G.map dateParse G.string))
        |> G.with (G.field "endDate" [] (G.map dateParse G.string))


student : G.ValueSpec G.NonNull G.ObjectType Student vars
student =
    G.object Student
        |> G.with (G.field "id" [] G.string)
        |> G.with (G.field "cohortId" [] G.string)
        |> G.with (G.field "firstName" [] G.string)
        |> G.with (G.field "github" [] G.string)
