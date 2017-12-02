module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Request)
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)


-- Request URL:
-- http://localhost:3000


validQueries :
    { divisions : String
    , finalApprover : String
    , firstApprover : String
    , functions : String
    , link : String
    , secondApprover : String
    , thirdApprover : String
    , typesOfExpenses : String
    , typeOfForm : String
    }
validQueries =
    { typeOfForm = "Type of Form"
    , divisions = "Divisions/Groups"
    , functions = "Functions"
    , firstApprover = "First Approver"
    , secondApprover = "Second Approver (if required)"
    , thirdApprover = "Third Approver (if required)"
    , finalApprover = "Final Approver (if required)"
    , link = "Link"
    , typesOfExpenses = "Types of Expenses"
    }


formsRequest : Request (List Form)
formsRequest =
    Http.get "http://localhost:3000" (Json.Decode.list formDecoder)


formDecoder : Json.Decode.Decoder Form
formDecoder =
    decode Form
        |> Json.Decode.Pipeline.required "Type of Form" Json.Decode.string
        |> Json.Decode.Pipeline.required "Divisions/Groups" Json.Decode.string
        |> Json.Decode.Pipeline.required "Functions" Json.Decode.string
        |> Json.Decode.Pipeline.required "First Approver" Json.Decode.string
        |> Json.Decode.Pipeline.required "Second Approver (if required)" Json.Decode.string
        |> Json.Decode.Pipeline.required "Third Approver (if required)" Json.Decode.string
        |> Json.Decode.Pipeline.required "Final Approver (if required)" Json.Decode.string
        |> Json.Decode.Pipeline.required "Link" Json.Decode.string
        |> Json.Decode.Pipeline.required "Types of Expenses" Json.Decode.string


type alias Form =
    { typeOfForm : String
    , divisions : String
    , functions : String
    , firstApprover : String
    , secondApprover : String
    , thirdApprover : String
    , finalApprover : String
    , link : String
    , typesOfExpenses : String
    }



---- MODEL ----


type alias Model =
    { forms : List Form
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    { forms = []
    , error = ""
    }
        ! []



---- UPDATE ----


type Msg
    = LoadForms
    | GotForms (List Form)
    | ShowError String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowError err ->
            { model | error = err } ! []

        GotForms forms ->
            { model | forms = forms } ! []

        LoadForms ->
            model
                ! [ Http.send
                        (\res ->
                            case res of
                                Ok forms ->
                                    GotForms forms

                                Err httpErr ->
                                    ShowError (toString httpErr)
                        )
                        formsRequest
                  ]



---- VIEW ----


view : Model -> Html Msg
view model =
    viewWrapper
        <| div []
            [ button [ onClick LoadForms ] [ text "Load Forms" ]
            , div []
                [ if List.length model.forms > 0 then
                    div [] (List.map formView model.forms)
                  else
                    p [] [ text "Lots of forms." ]
                ]
            , p [ style [ ( "color", "red" ) ] ] [ text model.error ]
            ]


viewWrapper : Html msg -> Html msg
viewWrapper content =
    div [ style [ ( "padding", "2em" ), ( "max-width", "350px" ), ( "margin", "0 auto" ) ] ]
        [ content ]


formView : Form -> Html Msg
formView form =
    div []
        [ h1 [] [ text ((.typeOfForm validQueries) ++ ": " ++ form.typeOfForm) ]
        , p [] [ text form.divisions ]
        , p [] [ text form.functions ]
        , p [] [ text form.firstApprover ]
        , p [] [ text form.secondApprover ]
        , p [] [ text form.thirdApprover ]
        , p [] [ text form.finalApprover ]
        , p [] [ text form.link ]
        , p [] [ text form.typesOfExpenses ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
