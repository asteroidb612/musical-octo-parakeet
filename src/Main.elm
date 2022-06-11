module Main exposing (main)

{-| 
    Simple Elm wrapper around the Airtable API.
    @docs main 
-}


import Browser
import Html as OldHtml exposing (Html)
---

import Http
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (requiredAt)

---

import Airtable

---
import Html.Styled exposing (..)

import Html.Styled.Attributes as Attr exposing (css)

import Svg

import Svg.Attributes 

import Tailwind.Utilities as Tw

import Tailwind.Breakpoints as Bp

import Css.Global

--- TYPES

type alias DB = {apiKey : String, base : String, table : String}

{-| 
    Use Environment Variables, DO NOT pass your API keys and other secrets this way. These values are for a dummy Airtable created expressly for this purpose.
    
-}


myDB = {apiKey = "keyyk8czRc9fUOnEm", base = "appYEFk7UbGTC0hyx", table = "Table%201"}   

type Model
  = Failure
  | Loading
  | Success (List Record)

type Msg
  = GotRecords(Result Http.Error (List Record))

type alias Record = 
    { name : String
    , address: String
    , picture: String
    , description : String
    }


--- JSON DECODERS

{-| 
    Airtable nests records two levels deep; an outer object titled "records", and inner elements titled "fields". This is why decoding is done in two stages, for each record, and then, for a list of records. In hindsight, "Record" was perhaps not the most ideal name for a type chosen, but YMMV.
    
-}


recordDecoder: Decoder Record
recordDecoder = 
    Decode.succeed Record
        |> requiredAt [ "fields", "Name"] Decode.string
        |> requiredAt [ "fields", "Address"] Decode.string
        |> requiredAt [ "fields", "Picture"] decodePicture
        |> requiredAt [ "fields", "Description"] Decode.string

decodePicture = 
    Decode.list (Decode.at ["url"] Decode.string)    
    |> Decode.andThen (\urls -> case List.head urls of 
        Just firstUrl -> Decode.succeed firstUrl
        Nothing -> Decode.fail "No urls"
    )

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
  , Airtable.getRecords myDB "Grid view" (Http.expectJson GotRecords recordsDecoder)

  )

--- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotRecords result ->
      case result of
        Ok records ->
          (Success records, Cmd.none)

        Err e ->
            let
                _ = Debug.log "" e
            in
            (Failure, Cmd.none)


--- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



--- VIEWS

    
view : Model -> OldHtml.Html Msg
view model = OldHtml.div [] [
    --Css.Global.global Tw.globalStyles,
  case model of
    Failure -> 
      OldHtml.text "Something went wrong"

    Loading ->
      OldHtml.text "elm-airtable loading"

    Success records ->
        interface records
        |> Html.Styled.toUnstyled
        ]


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

entryInterface : Record -> Html.Styled.Html msg
entryInterface {name, address, picture, description} = div
                    [ css
                        [ Tw.relative
                        , Tw.bg_white
                        , Tw.border
                        , Tw.border_gray_200
                        , Tw.rounded_lg
                        , Tw.flex
                        , Tw.flex_col
                        , Tw.overflow_hidden
                        ]
                    ]
                    [h2 [] [text name],
                    div
                        [ css
                            [ Tw.aspect_w_3
                            , Tw.aspect_h_4
                            , Tw.bg_gray_200
                            , Bp.sm
                                [ Tw.aspect_none
                                , Tw.h_96
                                ]
                            ]
                        ]
                        [  img
                            [ Attr.src picture
                            , Attr.alt name
                            , css
                                [ Tw.w_full
                                , Tw.h_full
                                , Tw.object_center
                                , Tw.object_cover
                                , Bp.sm
                                    [ Tw.w_full
                                    , Tw.h_full
                                    ]
                                ]
                            ]
                            []
                        ]

                        , div
                        [ css
                            [ Tw.flex_1
                            , Tw.p_4
                            , Tw.space_y_2
                            , Tw.flex
                            , Tw.flex_col
                            ]
                        ]
                        [ h3
                            [ css
                                [ Tw.text_sm
                                , Tw.font_medium
                                , Tw.text_gray_900
                                ]
                            ]
                            [ a
                                [ Attr.href "#"
                                ]
                                [ span
                                    [ Attr.attribute "aria-hidden" "true"
                                    , css
                                        [ Tw.absolute
                                        , Tw.inset_0
                                        ]
                                    ]
                                    []
                                , text name ]
                            ]
                        , p
                            [ css
                                [ Tw.text_sm
                                , Tw.text_gray_500
                                ]
                            ]
                            [ text address ]
                        , div
                            [ css
                                [ Tw.flex_1
                                , Tw.flex
                                , Tw.flex_col
                                , Tw.justify_end
                                ]
                            ]
                            [ p
                                [ css
                                    [ Tw.text_sm
                                    , Tw.italic
                                    , Tw.text_gray_500
                                    ]
                                ]
                                [ text description ]
                            ]
                        ]
                    ]
                 

interface : List Record -> Html.Styled.Html msg
interface records =   div
        [ css
            [ Tw.bg_white
            ]
        ]
        [ div
            [ css
                [ Tw.max_w_2xl
                , Tw.mx_auto
                , Tw.py_16
                , Tw.px_4
                , Bp.lg
                    [ Tw.max_w_7xl
                    , Tw.px_8
                    ]
                , Bp.sm
                    [ Tw.py_24
                    , Tw.px_6
                    ]
                ]
            ]
            [ h2
                [ css
                    [ Tw.sr_only
                    ]
                ]
                [ text "Products" ]
            , div
                [ css
                    [ Tw.grid
                    , Tw.grid_cols_1
                    , Tw.gap_y_4
                    , Bp.lg
                        [ Tw.grid_cols_3
                        , Tw.gap_x_8
                        ]
                    , Bp.sm
                        [ Tw.grid_cols_2
                        , Tw.gap_x_6
                        , Tw.gap_y_10
                        ]
                    ]
                ]
                [ div
                    [ css
                        [ Tw.relative
                        , Tw.bg_white
                        , Tw.border
                        , Tw.border_gray_200
                        , Tw.rounded_lg
                        , Tw.flex
                        , Tw.flex_col
                        , Tw.overflow_hidden
                        ]
                    ]
                    (List.map entryInterface records)                    
                ]
            ]
        ]
    