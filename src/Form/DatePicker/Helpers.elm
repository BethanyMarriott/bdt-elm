module Form.DatePicker.Helpers exposing (..)

import Date exposing (Date)
import Date.Bdt as Date

import List.Extra as List

import Form.Select as Select


toLabel : Date -> String
toLabel =
    dateToString


--toTimeLabel : Date -> String
--toTimeLabel posix =
--    dateToString (Date.fromPosix posix) ++ " " ++ timeToString posix
--
--
--timeToString : Int -> Int -> Int -> String
--timeToString date =
--
--    [Time.toHour Time.utc date, Time.toMinute Time.utc date, Time.toSecond Time.utc date]
--        |> List.map (String.fromInt >> String.padLeft 2 '0')
--        |> List.intersperse ":"
--        |> String.concat


dateToString : Date -> String
dateToString date =

    let
        day =
            date
                |> Date.day
                |> String.fromInt
                |> String.pad 2 '0'

        month =
            date
                |> Date.monthNumber
                |> String.fromInt
                |> String.pad 2 '0'

        year =
            date
                |> Date.year
                |> String.fromInt

    in
        String.join "/" [day, month, year]


maybeClamp : Maybe Date -> Maybe Date -> Date -> Date
maybeClamp maybeMinDate maybeMaxDate date =

    case (maybeMinDate, maybeMaxDate) of

        (Just minDate, Just maxDate) ->
            clamp minDate maxDate date

        (Just minDate, _) ->
            clamp minDate date date

        (_, Just maxDate) ->
            clamp date maxDate date

        _ ->
            date


clamp : Date -> Date -> Date -> Date
clamp minDate maxDate date =

    if Date.toRataDie date < Date.toRataDie minDate then
        minDate
    else if Date.toRataDie date > Date.toRataDie maxDate then
        maxDate
    else
        date


previousYear : Date -> Date
previousYear date =
    Date.add Date.Months -12 date


previousMonth : Date -> Date
previousMonth date =
    Date.add Date.Months -1 date


nextMonth : Date -> Date
nextMonth date =
    Date.add Date.Months 1 date


nextYear : Date -> Date
nextYear date =
    Date.add Date.Months 12 date


dateAtDayNumber : Int -> Date -> Date
dateAtDayNumber dayNumber date =
    Date.add Date.Days (dayNumber - 1) date


--dateFromTime : { time | hours : Select.Model String, minutes : Select.Model String, seconds : Select.Model String, selectedDate : Maybe Date } -> Maybe Date
--dateFromTime time =
--
--    case time.selectedDate of
--
--        Nothing ->
--            Nothing
--
--        Just selectedDate ->
--            let
--                year =
--                    Time.toYear Time.utc selectedDate
--
--                month =
--                    Time.toMonth Time.utc selectedDate
--
--                day =
--                    Time.toDay Time.utc selectedDate
--
--                hour =
--                    time.hours
--                        |> Select.getSelectedOption
--                        |> Maybe.map (String.toInt >> Result.toMaybe)
--                        |> Maybe.andThen identity
--                        |> Maybe.withDefault 0
--
--                minute =
--                    time.minutes
--                        |> Select.getSelectedOption
--                        |> Maybe.map (String.toInt >> Result.toMaybe)
--                        |> Maybe.andThen identity
--                        |> Maybe.withDefault 0
--
--                second =
--                    time.seconds
--                        |> Select.getSelectedOption
--                        |> Maybe.map (String.toInt >> Result.toMaybe)
--                        |> Maybe.andThen identity
--                        |> Maybe.withDefault 0
--
--            in
--                Just (Date.dateFromFields year month day hour minute second 0)


visibleDays : Date -> List (List (Bool, Int))
visibleDays navigationDate =

    let
        firstOfMonth =
            Date.add Date.Months -(Date.monthNumber navigationDate + 1) navigationDate

        startNumber =
            Date.weekdayNumber firstOfMonth

        daysInMonth =
            Date.daysInMonth navigationDate

        daysInPreviousMonth =
            previousMonth navigationDate |> Date.daysInMonth

        {-
            the 3 lists we're interested in:
                - the tail of the previous month (the disabled list at the front)
                - the current month (the enabled dates for this month)
                - the head of the next month (the disabled list as the end)
        -}

        currentMonth =
            List.range 1 daysInMonth
                |> List.map (Tuple.pair True)

        tailOfPreviousMonth =
            List.range 1 daysInPreviousMonth
                |> List.drop (daysInPreviousMonth - startNumber)
                |> List.map (Tuple.pair False)

        headOfNextMonth =
            List.range 1 (6 * 7 - startNumber - daysInMonth)
                |> List.map (Tuple.pair False)

    in
        -- bundle them up and split them in groups for each week
        tailOfPreviousMonth ++ currentMonth ++ headOfNextMonth
            |> List.groupsOf 7


intsToStrings : List Int -> List String
intsToStrings ints =
    List.map (String.fromInt >> String.padLeft 2 '0') ints


isSelectOpen : { time | hours : Select.Model String, minutes : Select.Model String, seconds : Select.Model String } -> Bool
isSelectOpen { hours, minutes, seconds } =

    [hours, minutes, seconds]
        |> List.map Select.getIsOpen
        |> List.any ((==) True)


isSame : Date -> Date -> Bool
isSame date1 date2 =
    Date.toRataDie date1 == Date.toRataDie date2