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
#?   If `[+-]` in the option is unset, it won't act like `/date/adjust-v`, an error
#?   will be returned.
#?   This is decided by the `GNU date` itself.
#?
#? Example:
#?   @adjust-d 2008-10-10 21 day
#?   2008-10-31
#?
#?   @adjust-d 2008-10-10 10 day ago
#?   2007-10-10
#?
#?   @adjust-d "2008-10-10 00:00:00" 30 minute 30 second
#?   2008-10-10 00:30:30
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
    #?    * TODO
    #?

    #? test whether the argument is for adjustment
    function __is_adjust_opt__ () {
        egrep -q '^[+-][0-9]{1,}[ymdwHMS]$|^[+-][a-zA-Z]{3,}$' <<< "$(echo "$1")"
    }

    #? test whether it's running into the highlight point 2
    function __has_weekday_opt__ () {
        egrep -q '[+-][a-zA-Z]{3,}' <<< "$(echo "$*")"
    }

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

    # translate BSD date style `-v` options to GNU date style `-d` options
    function __bsd_to_gnu__ () {
        local sign digi unit

        sign=${1:0:1}          # get first char
        digi=${1//[^0-9]/}     # remove non-digit
        unit=${1//[^a-zA-Z]/}  # remove non-letter

        local name
        case ${#unit} in
            1)
                # [ymdwHMS]
                name=$(__short_to_long__ "${unit}")

                if [[ -z $name ]]; then
                    printf "$FUNCNAME: ERROR: Invalid option: '%s' in '%s'.\n" "$unit" "$1" >&2
                    return 255
                fi

                if [[ -z $digi ]]; then
                    printf "$FUNCNAME: ERROR: Invalid option: no VALUE in '%s'.\n" "$1" >&2
                    return 255
                fi
                ;;
            *)
                weekday=$unit

                if [[ -n $digi ]]; then
                    printf "$FUNCNAME: ERROR: Invalid option: found VALUE '%s' in '%s'.\n" "$digi" "$1" >&2
                    return 255
                fi
                ;;
        esac

        local prefix= suffix=
        case $sign in
            +)
                if [[ -n $weekday ]]; then
                    prefix='next'
                fi
                ;;
            -)
                if [[ -n $weekday ]]; then
                    prefix='last'
                else
                    suffix=' ago'
                fi
                ;;
            *)
                printf "$FUNCNAME: ERROR: Invalid option: not starting with [+-]: '%s'\n" "$1" >&2
                return 255
                ;;
        esac

        echo "${prefix}${digi} ${name}${weekday}${suffix}"
    }

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

        local sign_of_target=${target:0:1}   # get the plus or minus sign

        local delta
        case $sign_of_target in
            [+-])
                delta=$(( (target - ${sign_of_target}base + 7) % 7 ))
                if [[ $delta -eq 0 ]]; then
                    delta=7
                fi
                delta=${sign_of_target}${delta}
                ;;
            [0-9])
                delta=$(( target - base ))
                if [[ $delta -ge 0 ]]; thne
                   delta=+$delta
                fi
                ;;
            *)
                return 255
                ;;
        esac

        echo "$delta"
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
            adjusts[${#adjusts[@]}]=$(__bsd_to_gnu__ "$1")
            shift
        done

        if [[ -z $ts ]]; then
            date -d "${adjusts[*]}" "${XSH_X_DATE__DATETIME_FMT:?}"
        else
            local fmt=$(xsh /date/parser "${ts}")
            date -d "${ts:?} ${adjusts[*]}" "+${fmt:?}"
        fi
    }

    function __adjust-d-recursive__ () {
        local ts

        if ! __is_adjust_opt__ "${@:(-1)}"; then
            # get last argument
            ts=${@:(-1)}

            # remove last argument from the argument list
            set -- "${@:1:$(($# - 1))}"
        fi

        local adjust=$(__bsd_to_gnu__ "$1")
        local result

        case ${adjust%% *} in
            last|next)
                local current=$(date -d "${ts}" +%u)  # 1 ~ 7
                local target=${1:0:1}$(date -d "${1:1}" +%u)  # -7 ~ +7

                local delta=$(__calc_delta_weekday__ "${current:?}" "${target:?}")
                result=$(__adjust-d__ "${delta}d" "${ts}")
                ;;
            *)
                local fmt=$(xsh /date/parser "${ts}")
                result="$(date -d "${ts} $adjust" "+${fmt}")"
                ;;
        esac

        shift
        if [[ $# -gt 0 ]]; then
            # Call recursively to get result
            result="$(__adjust-d-recursive__ "$@" "$result")"
        fi

        echo "$result"
    }


    if ! __is_adjust_opt__ "${@:(-1)}" && __has_weekday_opt__ "$*"; then
        __adjust-d-recursive__ "$@"
    else
        __adjust-d__ "$@"
    fi

    # clean env
    unset -f \
          __is_adjust_opt__ \
          __has_weekday_opt__ \
          __short_to_long__ \
          __bsd_to_gnu__ \
          __adjust-d__ \
          __adjust-d-recursive__
}
