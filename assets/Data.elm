module Data exposing (all)

import Http exposing (get)
import Json.Decode as Decode
import Json.Decode.Extra as Extra
import Json.Decode.Pipeline as Pipeline
import Types exposing (Cohort, Campus, Student)


-- DATA


all : Http.Request (List Campus)
all =
    graph
        (Field "campuses"
            [ Field "id" []
            , Field "name" []
            , Field "cohorts"
                [ Field "id" []
                , Field "startDate" []
                , Field "endDate" []
                , Field "students"
                    [ Field "id" []
                    , Field "firstName" []
                    , Field "lastName" []
                    , Field "github" []
                    ]
                ]
            ]
        )
        (Decode.at [ "data", "campuses" ]
            (Decode.list campusDecoder)
        )



-- SUPPORT


type Field
    = Field String (List Field)


fieldToString : Field -> String
fieldToString (Field name fields) =
    let
        append =
            if List.isEmpty fields then
                " "
            else
                fields
                    |> List.map fieldToString
                    |> List.foldr (++) ""
                    |> wrapWithBraces
    in
        name ++ append


graph : Field -> Decode.Decoder a -> Http.Request a
graph query decoder =
    let
        url =
            query
                |> fieldToString
                |> wrapWithBraces
                |> Http.encodeUri
                |> (++) "/graph?query="
    in
        get url decoder


wrapWithBraces : String -> String
wrapWithBraces =
    (++) "{"
        >> flip (++) "}"



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
