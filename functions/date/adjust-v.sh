#? Description:
#?   Adjust the second, minute, hour, month day, week day, month or year
#?   according to value.
#?
#?   If value is preceded with a plus or minus sign, the date is adjusted
#?   forwards or backwards according to the remaining string, otherwise
#?   the relevant part of the date is set.
#?
#?   The date can be adjusted as many times as requiried.
#?
#?   Works with "date -v" from Mac OS X.
#?
#? Usage:
#?   @adjust-v <TIMESTAMP>
#?             -v [+-][<VALUE>[ymwdHMS] | monday | tuesday | ...] [...]
#?
#? Example:
#?   @adjust-v 2008-10-10 -v +21d
#?   2008-10-31
#?
#?   @adjust-v 2008-10-10 -v -1y
#?   2007-10-10
#?
#?   @adjust-v "2008-10-10 00:00:00" -v +30M -v +30S
#?   2008-10-10 00:30:30
#?
function adjust-v () {
    local datetime fmt
    datetime=$1
    shift

    if [[ -z $datetime ]]; then
        date "$@" "+${DATETIME_FMT}"
    else
        fmt=$(xsh /date/parser "${datetime}")
        date "$@" -j -f "${fmt}" "${datetime}" "+${fmt}"
    fi
}
