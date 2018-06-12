module Form.FloatInput.Internal exposing
    ( State, ViewState
    , init, initialViewState
    , Msg, update
    , render
    , reInitialise, reset
    , setInitialValue, setValue, setDecimal
    , setPlaceholder, setMaxLength
    , setIsError, setIsLocked
    , setId
    , getIsChanged, getInitialValue, getValue
    , getId
    )

import Html exposing (..)
import Html.Lazy exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Regex exposing (Regex)

import Html.Bdt as Html exposing ((?))
import Resettable exposing (Resettable)


type alias State =
    { value : Resettable String
    , decimal : Int
    -- Add bypassLazy so that we can use lazy in render (so that external changes don't re-render),
    -- but still update the DOM to update the value on the input (to remove the letter).
    , bypassLazy : Int
    }


init : State
init =
    { value = Resettable.init ""
    , decimal = 0
    , bypassLazy = 0
    }


type alias ViewState =
    { maxLength : Maybe Int
    , placeholder : String
    , isLocked : Bool
    , isError : Bool
    , id : Maybe String
    }


initialViewState : ViewState
initialViewState =
    { maxLength = Nothing
    , placeholder = ""
    , isLocked = False
    , isError = False
    , id = Nothing
    }


-- UPDATE --


type Msg
    = Input String


update : Msg -> State -> State
update (Input string) state =

    case Regex.contains (Regex.regex ("^[-]?[0-9]*([.][0-9]{0," ++ toString state.decimal ++ "})?$")) string of

        True ->
            { state | value = Resettable.update string state.value }

        False ->
            { state | bypassLazy = state.bypassLazy + 1 }


-- VIEW --


render : State -> ViewState -> Html Msg
render state viewState =

    lazy2 inputField state viewState


inputField : State -> ViewState -> Html Msg
inputField state viewState =

    input
        [ class "bdt-elm input"
        , classList [("locked", viewState.isLocked), ("error", viewState.isError)]
        , disabled viewState.isLocked
        , value <| Resettable.getValue state.value
        , onInput Input
        , placeholder viewState.placeholder
        , Html.maybeAttribute maxlength viewState.maxLength
        , Html.maybeAttribute id viewState.id
        ]
        []


-- STATE SETTERS --


reInitialise : State -> State
reInitialise state =

    { state | value = Resettable.init <| Resettable.getValue state.value }


reset : State -> State
reset state =

    { state | value = Resettable.reset state.value }


setInitialValue : Float -> State -> State
setInitialValue value state =

    { state | value = Resettable.init (toString value) }


setValue : Float -> State -> State
setValue value state =

    { state | value = Resettable.update (toString value) state.value }


setDecimal : Int -> State -> State
setDecimal decimal state =

    { state | decimal = decimal }


-- VIEW STATE SETTERS --


setMaxLength : Int -> ViewState -> ViewState
setMaxLength maxLength viewState =

    { viewState | maxLength = Just maxLength }


setPlaceholder : String -> ViewState -> ViewState
setPlaceholder placeholder viewState =

    { viewState | placeholder = placeholder }


setIsLocked : Bool -> ViewState -> ViewState
setIsLocked isLocked viewState =

    { viewState | isLocked = isLocked }


setIsError : Bool -> ViewState -> ViewState
setIsError isError viewState =

    { viewState | isError = isError }


setId : String -> ViewState -> ViewState
setId id viewState =

    { viewState | id = Just id }


-- GETTERS --


getIsChanged : State -> Bool
getIsChanged state =

    Resettable.getIsChanged state.value


getInitialValue : State -> Maybe Float
getInitialValue =

    .value >> Resettable.getInitialValue >> stringToMaybeInt


getValue : State -> Maybe Float
getValue =

    .value >> Resettable.getValue >> stringToMaybeInt


stringToMaybeInt : String -> Maybe Float
stringToMaybeInt string =

    case string of

        "" ->
            Nothing

        value ->
            -- Don't use withDefault or mapError here, Debug.crash STILL gets called even if successful (compiler bug)
            case String.toFloat value of

                Err _ ->
                    Debug.crash "Failed to parse FloatInput String to Float"

                Ok int ->
                    Just int


getId : ViewState -> Maybe String
getId =
    .id