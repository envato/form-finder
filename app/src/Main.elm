module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on, keyCode)
import Http exposing (Request)
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)


-- Request URL:
-- http://localhost:3000/search/:term


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


formsRequest : String -> Request (List Form)
formsRequest term =
    Http.get ("http://localhost:3000/search/" ++ term)
        (Json.Decode.list formDecoder)


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
    , term : String
    }


init : ( Model, Cmd Msg )
init =
    { forms = []
    , error = ""
    , term = ""
    }
        ! []



---- UPDATE ----


type Msg
    = LoadForms
    | GotForms (List Form)
    | ShowError String
    | OnTerm String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTerm term ->
            { model | term = term } ! []

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
                        (formsRequest model.term)
                  ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.Decode.succeed msg
            else
                Json.Decode.fail "not ENTER"
    in
        on "keydown" (Json.Decode.andThen isEnter keyCode)



---- VIEW ----


view : Model -> Html Msg
view model =
    viewWrapper
        <| div []
            [ div []
                [ input [ type_ "text", placeholder "Search...", onInput OnTerm, onEnter LoadForms ] []
                ]
            , button [ onClick LoadForms ] [ text "Search" ]
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
        , a [ href form.link ] [ text form.link ]
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
