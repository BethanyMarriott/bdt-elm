module ToolTip exposing
    ( Model, init
    , Msg, update
    , view, render
    , top, left, bottom
    , green, red, blue
    )

{-| This module is useful if you want to add a ToolTip to your app.

# Initialise and update
@docs Model, init, Msg, update

# View and render
@docs view, render

# View Setters
@docs top, left, bottom, green, red, blue

-}

import Html.Styled as Html exposing (..)
import Html.Styled.Lazy exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Attributes as Attributes exposing (..)

import Html.Styled.Bdt as Html

import Css exposing (..)

import Color

import Content exposing (..)
import Icon exposing (Icon)


{-| Add a ToolTip.Model to your model.

    type alias MyModel =
        { myToolTip : ToolTip.Model
        }
-}
type Model =
    Model InternalState


type alias InternalState =
    { content : Content
    , tip : String
    , isOpen : Bool
    }

type View =
    View InternalState ViewState


type alias ViewState =
    { placement : Placement
    , color : ColorConfig
    }


initialViewState : ViewState
initialViewState =

    { placement = Right
    , color = Default
    }


type ColorConfig
    = Default
    | Blue
    | Green
    | Red


{-| The side of the icon the ToolTip should appear on.
-}
type Placement
    = Top
    | Bottom
    | Left
    | Right


{-|
}
} Init a ToolTip.Model in your model.

    myInitialModel : MyModel
    myInitialModel =
        { myToolTip = ToolTip.init
        }
-}
init : Content -> String -> Model
init content tip =

    Model <| InternalState content tip False


{-| Add a ToolTip.Msg to your Msg.

    type MyMsg
        = UpdateMyToolTip ToolTip.Msg
-}
type Msg
    = MouseEnter
    | MouseLeave


{-| Use in your update function.

    myUpdate : Msg -> Model -> (Model, Cmd Msg)
    myUpdate msg model =
        case msg of
            UpdateMyToolTip toolTipMsg ->
                let
                    (newToolTip, cmd) =
                        ToolTip.update toolTipMsg mode.myToolTip
                in
                    { model | myToolTip = newToolTip } ! [ cmd ]
-}
update : Msg -> Model -> Model
update msg (Model state) =

    case msg of

        MouseEnter ->

            Model { state | isOpen = True }

        MouseLeave ->

            Model { state | isOpen = False }


{-| Transform an ToolTip.Model into an ToolTip.View, which allows us to pipe View Setters on it.

    myView : Model -> Html Msg
    myView model =
        div
            []
            [ ToolTip.view model.myToolTip -- pipe view setters here, for example |> setPlacement Top
            ]
-}
view : Model -> View
view (Model state) =

    View state initialViewState


{-| Transforms an ToolTip.View into Html ToolTip.Msg

    myView : Model -> Html Msg
    myView model =
        div
            []
            [ ToolTip.render model.myToolTip
                |> Html.map UpdateMyToolTip
            ]
-}
render : View -> Html Msg
render (View state viewState) =

    div
        [ onMouseEnter MouseEnter
        , onMouseLeave MouseLeave
        , wrapper
        ]
        [ div
            [ contentWrapper viewState.color ]
            [ renderContent viewState.color state.content ]
        , Html.divIf state.isOpen
            [ tooltip viewState.placement ]
            [ text state.tip ]
        ]


renderContent : ColorConfig -> Content -> Html Msg
renderContent colorConfig content =

    case content of

        Icon icon ->
            Icon.render icon 18 (if colorConfig == Default then Color.black else Color.white)

        Text string ->
            Html.text string


{-| Set where the ToolTip will be placed relative to the icon
-}
setPlacement : Placement -> View -> View
setPlacement placement (View state viewState) =

    View state { viewState | placement = placement }


{-| Render the tip above the content
-}
top : View -> View
top (View state viewState) =

    View state { viewState | placement = Top }


{-| Render the tip left of the content
-}
left : View -> View
left (View state viewState) =

    View state { viewState | placement = Left }


{-| Render the tip below the content
-}
bottom : View -> View
bottom (View state viewState) =

    View state { viewState | placement = Bottom }


{-| Make the ToolTip green
-}
green : View -> View
green (View state viewState) =

    View state { viewState | color = Green }


{-| Make the ToolTip red
-}
red : View -> View
red (View state viewState) =

    View state { viewState | color = Red }


{-| Make the ToolTip blue
-}
blue : View -> View
blue (View state viewState) =

    View state { viewState | color = Blue }


contentWrapper : ColorConfig -> Attribute Msg
contentWrapper colorConfig =
    css
        [ backgroundColor <|
            case colorConfig of

                Green ->
                    hex "3FC380"

                Blue ->
                    hex "59ABE3"

                Red ->
                    hex "dc3545"

                Default ->
                    hex "ffffff"

        , color <|
            case colorConfig of

                Default ->
                    hex "000000"

                _ ->
                    hex "ffffff"
        , fontSize <| Css.rem 0.75
        , padding2 (Css.rem 0.2) (Css.rem 0.5)
        , borderRadius <| px 3
        , fontWeight bold
        , cursor Css.default
        ]


wrapper : Attribute Msg
wrapper =
    css
        [ displayFlex
        , position relative
        ]


tooltip : Placement -> Attribute Msg
tooltip placement =
    css <| List.append
        [ position absolute
        , boxShadow5 (px 0) (px 2) (px 8) (px 0) (rgb 110 110 110)
        , padding2 (Css.rem 0.3) (Css.rem 0.6)
        , borderRadius <| px 2
        , backgroundColor <| hex "fff"
        , cursor Css.default
        , fontFamilies
            [ "-apple-system", "system-ui", "BlinkMacSystemFont", "Segoe UI", "Roboto", "Helvetica Neue", "Arial", "sans-serif" ]
        , fontWeight <| int 100
        , fontSize <| Css.rem 0.75
        , color <| Css.rgb 90 90 90
        ]
        (placementPosition placement)


placementPosition : Placement -> List Style
placementPosition placement =

    case placement of

        Right ->
            [ Css.top <| Css.rem -0.25
            , Css.left <| Css.rem 1.75
            ]

        Top ->
            [ Css.top <| Css.rem -1.8
            , Css.left <| Css.rem 0
            ]

        Bottom ->
            [ Css.top <| Css.rem 1.5
            , Css.left <| Css.rem 0
            ]

        Left ->
            [ Css.top <| Css.rem -0.25
            , Css.left <| Css.rem -0.4
            , transform <| translateX (pct -100)
            ]


