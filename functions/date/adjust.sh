#? Description:
#?   A wrapper on BSD date and GNU date, provide uniform input syntax, try best to give
#?   the same result with the same input.
#?
#?   Adjust datetime by second, minute, hour, day, month, year, week
#?   number and weekday.
#?
#?   The output format will be the same as the input. The default output
#?   format is `%Y-%m-%d %H:%M:%S`.
#?
#?   The adjustment can be done as many times as requiried.
#?
#? Based:
#?   BSD date and GNU date.
#?
#? Tested:
#?   BSD date (May 7, 2015) under macOS.
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
#? Bugs with BSD date:
#?
#?   See: xsh help /date/adjust-v
#?
#? Bugs with GNU date:
#?
#?   See: xsh help /date/adjust-d
#?
#? Example:
#?   @adjust-v +21d 2008-10-10
#?   2008-10-31
#?
#?   @adjust-v +30M +30S "2008-10-10 00:00:00"
#?   2008-10-10 00:30:30
#?
#?   @adjust-v 21d 2008-10-10
#?   2008-10-21
#?
#?   @adjust-v +Mon 2008-10-10
#?   2008-10-13
#?
function adjust () {
    local adjusts datetime

    declare -a adjusts
    while [[ $# -gt 0 ]]; do
        case ${1:0:1} in
            +|-)
                adjusts[${#adjusts[@]}]=$1
                ;;
            [0-9])
                datetime=$1
                ;;
        esac
        shift
    done

    [[ -z ${datetime} ]] && datetime=$(xsh /date/timestamp)

    local i
    if xsh /date/is-compatible-date-v; then
        # prepend "-v "
        for i in "${!adjusts[@]}"; do
            adjusts[$i]="-v ${adjusts[$i]}"
        done
        xsh /date/adjust-v "${datetime}" ${adjusts[@]}

    elif xsh /date/is-compatible-date-d; then
        for i in "${!adjusts[@]}"; do
            case ${adjusts[$i]:1:1} in
                [0-9])
                    # traslate [+-]<N>[ymwdHMS]
                    adjusts[$i]=$(
                        echo "${adjusts[$i]}" \
                            | sed -e 's/y$/ year/' \
                                  -e 's/m$/ month/' \
                                  -e 's/w$/ week/' \
                                  -e 's/d$/ day/' \
                                  -e 's/H$/ hour/' \
                                  -e 's/M$/ minute/' \
                                  -e 's/S$/ second/'
                           )
                    ;;
                [a-zA-Z])
                    # traslate [+-][monday ...]
                    adjusts[$i]=$(
                        echo "${adjusts[$i]}" \
                            | sed -e 's/^-/last-/' \
                                  -e 's/^+/next-/'
                           )
                    ;;
                *)
                    return 255
                    ;;
            esac
        done

        xsh /date/adjust-d "${datetime}" "${adjusts[@]}"
    else
        xsh /date/adjust-z "{datetime}" "${adjusts[@]}"
    fi
}
