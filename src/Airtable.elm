module Airtable exposing (getRecords)

{-| 
    Based on https://github.com/altjsus/elmtable. Intended as a read-only GET/HTTPS based Airtable-as-CMS. Only reads multiple records
    @docs getRecords
-}

import Http
import Url.Builder
import Http exposing (..)

type alias DB = {apiKey : String, base : String, table : String}

{-| 
    GET a list of records from an Airtable Table, by passing it a Base, View, and an Http.ExpectJSON
-}
--getRecords db dbView maxRecords pageSize offset expect =
getRecords: DB -> String -> Expect msg -> Cmd msg
getRecords db dbView expect =
    Http.request {
        method = "GET"
        , headers = [Http.header "Authorization" ("Bearer " ++ db.apiKey)]
        , url = "https://api.airtable.com/v0" ++ 
            (Url.Builder.absolute [db.base, db.table] 
                [
                    Url.Builder.string "view" dbView
                    --Url.Builder.int "maxRecords" maxRecords, 
                    --Url.Builder.int "pageSize" pageSize, 
                    --Url.Builder.int "offset" offset
                ]
            )
        , expect = expect
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
    }