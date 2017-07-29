module Data exposing (queryAllData, mutationNewCohort)

import Date
import Types exposing (Cohort, Campus, Student, AllData)
import GraphQL.Request.Builder as G
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


queryAllData : G.Request G.Query AllData
queryAllData =
    let
        query : G.Document G.Query AllData vars
        query =
            G.queryDocument <|
                (G.object AllData
                    |> G.with (G.field "campuses" [] (G.list campus))
                    |> G.with (G.field "cohorts" [] (G.list cohort))
                    |> G.with (G.field "students" [] (G.list student))
                )
    in
        G.request () query


mutationNewCohort : String -> String -> String -> G.Request G.Mutation Cohort
mutationNewCohort startDate endDate campusId =
    let
        mutation : G.Document G.Mutation Cohort { a | campusId : String, endDate : String, startDate : String }
        mutation =
            G.mutationDocument <|
                G.extract <|
                    G.field "cohort"
                        [ ( "startDate", Arg.variable (Var.required "startDate" .startDate Var.string) )
                        , ( "endDate", Arg.variable (Var.required "endDate" .endDate Var.string) )
                        , ( "campusId", Arg.variable (Var.required "campusId" .campusId Var.string) )
                        ]
                        cohort
    in
        G.request
            { startDate = startDate
            , endDate = endDate
            , campusId = campusId
            }
            mutation



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
        |> G.with (G.field "lastName" [] G.string)
        |> G.with (G.field "github" [] G.string)



-- HELPERS


dateParse : String -> Date.Date
dateParse =
    Date.fromString
        >> Result.withDefault (Date.fromTime 0)
