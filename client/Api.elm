module Api exposing (fetchCampuses)

import Helpers exposing (dateParse)
import Model exposing (CohortWithoutNum, CampusWithoutNum, Student)
import GraphQL.Client.Http as Http
import GraphQL.Request.Builder exposing (ValueSpec, NonNull, ObjectType, queryDocument, extract, field, list, map, nullable, object, request, string, with)
import Task exposing (Task)


fetchCampuses : String -> Task Http.Error (List CampusWithoutNum)
fetchCampuses url =
    Http.sendQuery url <|
        request () <|
            queryDocument <|
                extract <|
                    field "allCampuses" [] <|
                        list campus



-- GRAPHQL TYPES


campus : ValueSpec NonNull ObjectType CampusWithoutNum vars
campus =
    object CampusWithoutNum
        |> with (field "id" [] string)
        |> with (field "name" [] string)
        |> with (field "cohorts" [] (list cohort))


cohort : ValueSpec NonNull ObjectType CohortWithoutNum vars
cohort =
    object CohortWithoutNum
        |> with (field "id" [] string)
        |> with (field "startDate" [] (map dateParse string))
        |> with (field "endDate" [] (map dateParse string))
        |> with (field "students" [] (list student))


student : ValueSpec NonNull ObjectType Student vars
student =
    object Student
        |> with (field "id" [] string)
        |> with (field "firstName" [] string)
        |> with (field "github" [] <| nullable string)
