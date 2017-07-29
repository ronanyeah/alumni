module Data exposing (queryAllData, mutationNewCohort, mutationNewStudent)

import Date
import Helpers
import Types exposing (Cohort, Campus, Student, AllData, StudentForm, CohortForm)
import GraphQL.Request.Builder as G
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


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


mutationNewCohort : CohortForm -> G.Request G.Mutation Cohort
mutationNewCohort form =
    let
        mutation : G.Document G.Mutation Cohort CohortForm
        mutation =
            G.field "cohort"
                [ ( "startDate", Arg.variable (Var.required "startDate" (.startDate >> Helpers.formatDate) Var.string) )
                , ( "endDate", Arg.variable (Var.required "endDate" (.endDate >> Helpers.formatDate) Var.string) )
                , ( "campusId", Arg.variable (Var.required "campusId" .campusId Var.string) )
                ]
                cohort
                |> G.extract
                |> G.mutationDocument
    in
        G.request form mutation


mutationNewStudent : StudentForm -> G.Request G.Mutation Student
mutationNewStudent form =
    let
        mutation : G.Document G.Mutation Student StudentForm
        mutation =
            G.field "student"
                [ ( "cohortId", Arg.variable (Var.required "cohortId" .cohortId Var.string) )
                , ( "firstName", Arg.variable (Var.required "firstName" .firstName Var.string) )
                , ( "lastName", Arg.variable (Var.required "lastName" .lastName Var.string) )
                , ( "github", Arg.variable (Var.required "github" .github Var.string) )
                ]
                student
                |> G.extract
                |> G.mutationDocument
    in
        G.request form mutation



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
