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
#?   BSD date.
#?
#? Tested:
#?   BSD date (May 7, 2015) under macOS.
#?
#? Usage:
#?   @adjust-v
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
#?   1. If use `+<WEEKDAY>` multiple times, the last one overrides all formers.
#?      This is decided by `BSD date` itself. Use `[+-]<N>w` for this situation.
#?
#? Example:
#?   $ @adjust-v +21d 2008-10-10
#?   2008-10-31
#?
#?   $ @adjust-v +30M +30S "2008-10-10 00:00:00"
#?   2008-10-10 00:30:30
#?
#?   $ @adjust-v 21d 2008-10-10
#?   2008-10-21
#?
#?   $ @adjust-v +Mon 2008-10-10
#?   2008-10-13
#?
function adjust-v () {

    #? Highlight for BSD date (May 7, 2015) under macOS.
    #?
    #? 1. `date -v [+-]<WEEKDAY>`
    #?
    #?    * +<WEEKDAY>   get next coming <WEEKDAY>.
    #?                   If <WEEKDAY> is today, get today.
    #?    * -<WEEKDAY>   get last <WEEKDAY> in the past.
    #?                   If <WEEKDAY> is today, get today.
    #?    * <WEEKDAY>    get <WEEKDAY> in this week.
    #?

    # get the last argument
    local ts=${@:(-1)}

    local opt_v_regexp='^[+-]?[0-9]{1,}[ymdwHMS]$|^[+-]{1}(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$'

    if echo "$ts" \
            | egrep -q "$opt_v_regexp"; then
        # not a timestamp
        unset ts
    else
        # remove last argument from the argument list
        set -- "${@:0:$#}"
    fi

    # prefix `-v ` for each argument
    adjusts=( ${@/#/-v } )

    if [[ -z $ts ]]; then
        date "${adjusts[@]}" "${XSH_X_DATE__DATETIME_FMT:?}"
    else
        local fmt=$(xsh /date/parser "${ts}")
        date "${adjusts[@]}" -j -f "${fmt:?}" "${ts}" "+${fmt:?}"
    fi
}
