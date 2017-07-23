module Data exposing (campuses, all)

import Http exposing (get)
import Json.Decode as Decode
import Json.Decode.Extra as Extra
import Json.Decode.Pipeline as Pipeline
import Types exposing (Cohort, Campus, Student)


-- DATA


campuses : Http.Request (List Campus)
campuses =
    graph
        (Query
            [ f "campuses"
                [ f "id" []
                , f "name" []
                ]
            ]
        )
        (Decode.at [ "data", "campuses" ] <|
            Decode.list campusDecoder
        )


all : Http.Request (List Campus)
all =
    graph
        (Query
            [ f "campuses"
                [ f "id" []
                , f "name" []
                , f "cohorts"
                    [ f "id" []
                    , f "startDate" []
                    , f "endDate" []
                    , f "students"
                        [ f "id" []
                        , f "firstName" []
                        , f "lastName" []
                        , f "github" []
                        ]
                    ]
                ]
            ]
        )
        (Decode.at [ "data", "campuses" ]
            (Decode.list campusDecoder)
        )



-- SUPPORT


type Field
    = Field String Query


type Query
    = Query (List Field)


f : String -> List Field -> Field
f name fields =
    Field name (Query fields)


queryToString : Query -> String
queryToString (Query query) =
    if List.isEmpty query then
        ""
    else
        query
            |> List.map fieldToString
            |> List.foldr (++) ""
            |> (++) "{"
            |> flip (++) "}"


fieldToString : Field -> String
fieldToString (Field name query) =
    name ++ " " ++ queryToString query


graph : Query -> Decode.Decoder a -> Http.Request a
graph query decoder =
    let
        url =
            query
                |> queryToString
                |> Http.encodeUri
                |> (++) "/graph?query="
    in
        get url decoder



-- DECODERS


campusDecoder : Decode.Decoder Campus
campusDecoder =
    Pipeline.decode Campus
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "cohorts" (Decode.list cohortDecoder) []


cohortDecoder : Decode.Decoder Cohort
cohortDecoder =
    Pipeline.decode Cohort
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "startDate" Extra.date
        |> Pipeline.required "endDate" Extra.date
        |> Pipeline.optional "students" (Decode.list studentDecoder) []


studentDecoder : Decode.Decoder Student
studentDecoder =
    Pipeline.decode Student
        |> Pipeline.required "id" Decode.string
        |> Pipeline.required "firstName" Decode.string
        |> Pipeline.required "lastName" Decode.string
        |> Pipeline.required "github" Decode.string
