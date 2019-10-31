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
#?   @adjust
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
#?   $ @adjust +21d 2008-10-10
#?   2008-10-31
#?
#?   $ @adjust +30M +30S "2008-10-10 00:00:00"
#?   2008-10-10 00:30:30
#?
#?   $ @adjust 21d 2008-10-10
#?   2008-10-21
#?
#?   $ @adjust +Mon 2008-10-10
#?   2008-10-13
#?
function adjust () {
    if xsh /date/is-compatible-date-v; then
        xsh /date/adjust-v "$@"
    elif xsh /date/is-compatible-date-d; then
        xsh /date/adjust-d "$@"
    else
        xsh log error "not found the capable date util."
        return 255
    fi
}
