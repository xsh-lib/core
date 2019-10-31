#? Description:
#?   Adjust datetime by second, minute, hour, day, month, year, week
#?   number and weekday.
#?
#?   The output format will be the same as the input. The default output
#?   format is `%Y-%m-%d %H:%M:%S`.
#?
#?   The adjustment can be done as many times as requiried.
#?
#? Based:
#?   GNU date.
#?
#? Tested:
#?   GNU date (GNU coreutils) 8.22 under Linux.
#?
#? Usage:
#?   @adjust-d
#?     [+-]<VALUE><y | m | w | d | H | M | S> [...]
#?     [+-]<Mon | Tue | Wed | Thu | Fri | Sat | Sun> [...]
#?     [TIMESTAMP]
#?
#? Options:
#?   [+-]         Adjust forward or backword.
#?
#?   <VALUE>      If value is preceded by a plus or minus sign, the date is adjusted
#?                forwards or backwards according to the remaining string, otherwise
#?                the relevant part of the date is set to the VALUE.
#?
#?   y            Year.
#?   m            Month.
#?   w            Week.
#?   d            Day.
#?   H            Hour.
#?   M            Minute.
#?   S            Second.
#?
#?   <Mon | ...>  Weeks.
#?
#?   [TIMESTAMP]  Base timestamp. If omitted current datetime is used.
#?
#? Bugs:
#?
#?   1. `@adjust-d +1d Mon`
#?      Avoid to use single weekday as the optional [TIMESTAMP], it will be recognized
#?      as adjustment option of unsigned weekday.
#?
#?   2. `@adjust-d 100y`
#?      Use unsigned year adjustment option with caution.
#?      Unlike `BSD date`, @adjust-d won't check the valid of the setting year, and
#?      won't handle following mapping:
#?
#?      * `2000: 00-68`
#?      * `1900: 69-99`
#?      * `1900: 100-1900`
#?      * `0000: 1901-`
#?
#? Example:
#?   $ @adjust-d +21d 2008-10-10
#?   2008-10-31
#?
#?   $ @adjust-d +30M +30S "2008-10-10 00:00:00"
#?   2008-10-10 00:30:30
#?
#?   $ @adjust-d 21d 2008-10-10
#?   2008-10-21
#?
#?   $ @adjust-d +Mon 2008-10-10
#?   2008-10-13
#?
function adjust-d () {

    #? Highlight for GNU date (GNU coreutils) 8.22 under Linux.
    #?
    #? 1. `date -d [DATE] [+-]<NUM> <NAME>`
    #?
    #?    * Without DATE, it works as expected.
    #?    * With DATE, it turns into timezone adjustment.
    #?
    #?    SOLUTION:
    #?
    #?    * Use syntax: `date -d [DATE] <NUM> <NAME> [ago]`.
    #?
    #? 2. `date -d [DATE] [last | next] <WEEKDAY>`
    #?
    #?    * Without DATE, it works as expected.
    #?        * last <WEEKDAY>   get next coming <WEEKDAY>.
    #?                           If <WEEKDAY> is today, get <WEEKDAY> of next week.
    #?        * next <WEEKDAY>   get last <WEEKDAY> in the past.
    #?                           If <WEEKDAY> is today, get <WEEKDAY> of last week.
    #?        * <WEEKDAY>        get <WEEKDAY> in this week.
    #?    * With DATE, it always return the input DATE.
    #?
    #?    SOLUTION:
    #?
    #?    * Use user-defined function to handle the logic.
    #?
    #? 3. Equivalent of BSD date `date -v <NUM>[ymdwHMS]`
    #?
    #?    * GNU date doesn't support to set a specific part of date.
    #?
    #?    SOLUTION:
    #?
    #?    * Use user-defined function to handle the logic.
    #?

    #? test whether the argument is for adjustment
    function __is_adjust_opt__ () {
        egrep -q '^[+-]?[0-9]{1,}[ymdwHMS]$|^[+-]?[a-zA-Z]{3,}$' <<< "$1"
    }

    #? test whether it's running into the highlight point 2
    function __has_weekday_opt__ () {
        egrep -q '[+-]?[a-zA-Z]{3,}' <<< "$*"
    }

    #? test whether it's running into the highlight point 3
    function __has_unsigned_opt__ () {
        egrep -q '(^| )[0-9]{1,}[a-zA-Z]' <<< "$*"
    }

    # translate BSD date style `-v` options to GNU date style `-d` options
    function __bsd_to_gnu__ () {

        #? translate short names to long names
        function __short_to_long__ () {
            case $1 in
                y) echo year;;
                m) echo month;;
                d) echo day;;
                w) echo week;;
                H) echo hour;;
                M) echo minute;;
                S) echo second;;
                *) return 255;;
            esac
        }

        local sign digi unit

        sign=${1:0:1}          # get first char
        digi=${1//[^0-9]/}     # remove non-digit
        unit=${1//[^a-zA-Z]/}  # remove non-letter

        local name weekday
        case ${#unit} in
            1)
                # [ymdwHMS]
                name=$(__short_to_long__ "$unit")

                # clean env
                unset -f __short_to_long__

                if [[ -z $name ]]; then
                    xsh log error "$1: invalid option: invalid UNIT: '$unit'"
                    return 255
                fi

                if [[ -z $digi ]]; then
                    xsh log error "$1: invalid option: VALUE is missing."
                    return 255
                fi
                ;;
            *)
                weekday=$unit

                if [[ -n $digi ]]; then
                    xsh log error "$1: invalid option: invlid VALUE: '$digi'"
                    return 255
                fi
                ;;
        esac

        local prefix= suffix=
        case $sign in
            +)
                if [[ -n $weekday ]]; then
                    echo "next $weekday"
                else
                    echo "$digi $name"
                fi
                ;;
            -)
                if [[ -n $weekday ]]; then
                    echo "last $weekday"
                else
                    echo "$digi $name ago"
                fi
                ;;
            *)
                xsh log error "$1: invalid option: not started with [+-]."
                return 255
                ;;
        esac
    }

    function __adjust-d__ () {
        local ts

        if ! __is_adjust_opt__ "${@:(-1)}"; then
            # get last argument
            ts=${@:(-1)}

            # remove last argument from the argument list
            set -- "${@:1:$(($# - 1))}"
        fi

        declare -a adjusts

        # translate `BSD date` style options to `GNU date` style.
        while [[ $# -gt 0 ]]; do
            adjusts+=( "$(__bsd_to_gnu__ "$1")" )
            shift
        done

        if [[ -z $ts ]]; then
            date -d "${adjusts[*]}" "${XSH_X_DATE__DATETIME_FMT:?}"
        else
            local fmt=$(xsh /date/parser "${ts}")
            date -d "${ts:?} ${adjusts[*]}" "+${fmt:?}"
        fi
    }

    function __adjust-d-signle-step__ () {

        #? Calculate the delta days between the base weekday and the target weekday.
        #?
        #? Usage:
        #?   __calc_delta_weekday__ <BASE> <TARGET>
        #?
        #? Options:
        #?   <BASE>    Base weekday: [1-7]
        #?
        #?   <TARGET>  Target weekday: [+-][1-7]
        #?             With leading [+-], the target weekday is the next coming
        #?             weekday or the weekday in the past.
        #?             Without leading [+-], the target weekday is the weekday
        #?             of this week.
        #?
        #? Output:
        #?   -13 ~ +13
        function __calc_delta_weekday__ () {
            local base=${1:?}
            local target=${2:?}

            local sign_of_target=${target//[^+-]/}  # remove none [+-]

            local delta
            case $sign_of_target in
                [+-])
                    delta=$(( (target - ${sign_of_target}base + 7) % 7 ))
                    if [[ $delta -eq 0 ]]; then
                        delta=7
                    fi
                    delta=${sign_of_target}${delta}
                    ;;
                *)
                    delta=$((target - base))
                    if [[ $delta -ge 0 ]]; then
                       delta=+$delta
                    fi
                    ;;
            esac

            echo "$delta"
        }

        local ts

        if __is_adjust_opt__ "${@:(-1)}"; then
            ts=$(date "${XSH_X_DATE__DATETIME_FMT:?}")
        else
            # get last argument
            ts=${@:(-1)}

            # remove last argument from the argument list
            set -- "${@:1:$(($# - 1))}"
        fi

        local result

        local sign=${1//[^+-]/}  # remove none [+-]
        local unit=${1//[^a-zA-Z]/}  # remove non-letter

        if __has_weekday_opt__ "$1"; then
            local current=$(date -d "$ts" +%u)  # 1 ~ 7
            local target=$(date -d "$unit" +%u)  # 1 ~ 7

            local delta=$(__calc_delta_weekday__ "${current:?}" "$sign${target:?}")
            result=$(__adjust-d__ "${delta}d" "$ts")
        else
            case $sign in
                [+-])
                    local adjust=$(__bsd_to_gnu__ "$1")
                    local fmt=$(xsh /date/parser "$ts")
                    result="$(date -d "$ts $adjust" "+${fmt}")"
                    ;;
                *)
                    local digi=${1//[^0-9]/}  # remove non-digit

                    # hyphen `-`: don't pad the field
                    # lower `y` to upper `Y`: get year with Century
                    local current=$(date -d "$ts" +%-${unit/y/Y})

                    local delta=$((digi - current))
                    if [[ $delta -ge 0 ]]; then
                        delta=+$delta
                    fi

                    result=$(__adjust-d__ "$delta$unit" "$ts")
                    ;;
            esac
        fi

        shift
        if [[ $# -gt 0 ]]; then
            # Call signle-steply to get result
            result="$(__adjust-d-signle-step__ "$@" "$result")"
        fi

        # clean env
        unset -f __calc_delta_weekday__

        echo "$result"
    }


    if __has_weekday_opt__ "$*" || __has_unsigned_opt__ "$*"; then
        # handle logic of highlight point 2 and 3
        __adjust-d-signle-step__ "$@"

    else
        __adjust-d__ "$@"
    fi

    # clean env
    unset -f \
          __is_adjust_opt__ \
          __has_weekday_opt__ \
          __has_unsigned_opt__ \
          __bsd_to_gnu__ \
          __adjust-d__ \
          __adjust-d-signle-step__
}
