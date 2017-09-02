module Api exposing (fetchAvatars, fetchCampuses)

import Dict exposing (Dict)
import Helpers exposing (dateParse)
import Http exposing (header)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Client.Http exposing (Error, sendQuery, customSendQuery)
import GraphQL.Request.Builder exposing (Field, ValueSpec, NonNull, ObjectType, SelectionSpec, aliasAs, dict, queryDocument, extract, field, list, map, nullable, object, request, string, with)
import Model exposing (CohortWithoutNum, CampusWithoutNum, Student)
import Murmur3 exposing (hashString)
import Task exposing (Task)


fetchCampuses : String -> Task Error (List CampusWithoutNum)
fetchCampuses url =
    sendQuery url <|
        request () <|
            queryDocument <|
                extract <|
                    field "allCampuses" [] <|
                        list campus


userAvatarUrlField : String -> SelectionSpec Field String vars
userAvatarUrlField name =
    aliasAs ("G" ++ (name |> hashString 1234 |> toString)) <|
        field "user"
            [ ( "login", Arg.string name ) ]
        <|
            extract <|
                field "avatarUrl" [] string


fetchAvatars : String -> List String -> Task Error (Dict String String)
fetchAvatars token usernames =
    customSendQuery
        { method = "POST"
        , headers = [ header "Authorization" <| "Bearer " ++ token ]
        , url = "https://api.github.com/graphql"
        , timeout = Nothing
        , withCredentials = False
        }
    <|
        request () <|
            queryDocument <|
                dict <|
                    List.map userAvatarUrlField usernames



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
