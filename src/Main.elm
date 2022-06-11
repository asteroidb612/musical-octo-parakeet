module Main exposing (main)

{-| 
    Simple Elm wrapper around the Airtable API.
    @docs main 
-}


import Browser
import Html exposing (Html)
import Html.Attributes

---

import Http
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (requiredAt)
import Element exposing (..)

---

import Airtable


--- TYPES

type alias DB = {apiKey : String, base : String, table : String}

{-| 
    Use Environment Variables, DO NOT pass your API keys and other secrets this way. These values are for a dummy Airtable created expressly for this purpose.
    
-}


myDB = {apiKey = "keyWeDr2vJl8zd3mG", base = "appFMiCjufAGkO5X4", table = "Examples"}   


type Model
  = Failure
  | Loading
  | Success (List Record)

type Msg
  = GotRecords(Result Http.Error (List Record))

type alias Record = 
    { name : String
    , job: String
    }


--- JSON DECODERS

{-| 
    Airtable nests records two levels deep; an outer object titled "records", and inner elements titled "fields". This is why decoding is done in two stages, for each record, and then, for a list of records. In hindsight, "Record" was perhaps not the most ideal name for a type chosen, but YMMV.
    
-}


recordDecoder: Decoder Record
recordDecoder = 
    Decode.succeed Record
        |> requiredAt [ "fields", "Name"] Decode.string
        |> requiredAt [ "fields", "Job"] Decode.string

recordsDecoder : Decoder (List Record)
recordsDecoder =
  Decode.field "records" (Decode.list recordDecoder)


--- INIT

{-| 
    Here, we are passing an Airtable View ("Main" in our case). If you don;t do so, records are randomly ordered. Naming a View allows the end user to sort as they wish using Airtable's simple and excellent UI.
    
-}

--- 

init : () -> (Model, Cmd Msg)
init _ =
  ( Loading

  --, Airtable.getRecords myDB "Main" 100 100 0 (Http.expectJson GotRecords recordsDecoder)
  , Airtable.getRecords myDB "Main" (Http.expectJson GotRecords recordsDecoder)

  )

--- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotRecords result ->
      case result of
        Ok records ->
          (Success records, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)


--- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



--- VIEWS

{-| 
    The final view is a bare-bones MVP-style display of Airtable data. Styling is left upto the reader.
    
-}

recordView : List Record -> Element Msg
recordView records = 
    column []
        [ Element.html (
            Html.ul [] 
                (List.map 
                    (\x -> (
                        Html.li [] [ Html.text (x.job ++ " " ++ x.name) ]
                    )
                ) records )
            )
        ]            


airtableView : List Record -> Html Msg
airtableView records = 
    layout [] <| column [][ recordView records ]


view : Model -> Html Msg
view model =
  case model of
    Failure -> 
      Html.text "Something went wrong"

    Loading ->
      Html.text "elm-airtable loading"

    Success records ->
        airtableView records


--- MAIN

{-| 
    main
     
-}
main: Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }