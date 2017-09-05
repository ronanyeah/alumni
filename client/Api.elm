module Api exposing (fetchAvatars, fetchCampuses)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Client.Http exposing (Error, sendQuery, customSendQuery)
import GraphQL.Request.Builder exposing (Field, ValueSpec, NonNull, ObjectType, SelectionSpec, aliasAs, keyValuePairs, queryDocument, extract, field, list, map, nullable, object, request, string, with)
import Helpers exposing (dateParse)
import Http exposing (header)
import Model exposing (CohortWithoutNum, CampusWithoutNum, Student)
import Task exposing (Task)


fetchCampuses : String -> Task Error (List CampusWithoutNum)
fetchCampuses url =
    sendQuery url <|
        request () <|
            queryDocument <|
                extract <|
                    field "allCampuses" [] <|
                        list campus


userAvatarUrlField : String -> SelectionSpec Field (Maybe String) vars
userAvatarUrlField username =
    field "user"
        [ ( "login", Arg.string username ) ]
    <|
        -- nullable as github username may not exist
        nullable
        <|
            extract <|
                field "avatarUrl" [] string


fetchAvatars : String -> List String -> Task Error (List ( String, Maybe String ))
fetchAvatars token usernames =
    usernames
        |> List.indexedMap
            (\index username ->
                -- appending a letter to satisfy the spec:
                -- https://facebook.github.io/graphql/#sec-Names
                aliasAs ("g" ++ toString index) (userAvatarUrlField username)
            )
        |> keyValuePairs
        |> queryDocument
        |> request ()
        |> customSendQuery
            { method = "POST"
            , headers = [ header "Authorization" <| "Bearer " ++ token ]
            , url = "https://api.github.com/graphql"
            , timeout = Nothing
            , withCredentials = False
            }
        |> Task.map
            -- The aliases are just indexes,
            -- so here I am discarding them and pairing up the usernames again.
            (List.map2
                (\username ( _, maybeUrl ) ->
                    ( username, maybeUrl )
                )
                usernames
            )



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
