module Data exposing (campusQuery, campusRequest, createCohort)

import Date
import Http exposing (post, emptyBody)
import Json.Decode as Decode
import Types exposing (Cohort, Campus, Student)
import GraphQL.Request.Builder as G


campusQuery : G.Document G.Query (List Campus) vars
campusQuery =
    let
        campus =
            G.object Campus
                |> G.with (G.field "id" [] G.string)
                |> G.with (G.field "name" [] G.string)
                |> G.with (G.field "cohorts" [] (G.list cohort))

        dateParse : String -> Date.Date
        dateParse =
            Date.fromString
                >> Result.withDefault (Date.fromTime 0)

        cohort =
            G.object Cohort
                |> G.with (G.field "id" [] G.string)
                |> G.with (G.field "startDate" [] (G.map dateParse G.string))
                |> G.with (G.field "endDate" [] (G.map dateParse G.string))
                |> G.with (G.field "students" [] (G.list student))

        student =
            G.object Student
                |> G.with (G.field "id" [] G.string)
                |> G.with (G.field "firstName" [] G.string)
                |> G.with (G.field "lastName" [] G.string)
                |> G.with (G.field "github" [] G.string)
    in
        G.queryDocument <|
            G.extract <|
                G.field "campuses"
                    []
                    (G.list campus)


campusRequest : G.Request G.Query (List Campus)
campusRequest =
    G.request () campusQuery


createCohort : String -> String -> String -> Http.Request Decode.Value
createCohort startDate endDate campus =
    let
        query =
            "mutation{ cohort(campus_id: \"" ++ campus ++ "\" startDate: \"" ++ startDate ++ "\" endDate: \"" ++ endDate ++ "\") { id } }"

        url =
            query
                |> Http.encodeUri
                |> (++) "/graph?query="
    in
        post url emptyBody Decode.value
