#? Description:
#?   Count the number of leap month in the future or past <VALUE> years since
#?   the given date.
#?
#? Usage:
#?   @count [+|-]<VALUE> [TIMESTAMP]
#?
#? Options:
#?   +<VALUE>     Go forward <VALUE> years, `+` could be omitted.
#?   -<VALUE>     Go backward <VALUE> years.
#?   [TIMESTAMP]  Base timestamp. If omitted current datetime is used.
#?
#? Example:
#?   @count +10 2008-01-01
#?   3
#?
#?   @count -10 2008-01-01
#?   2
#?
function count () {
    declare offset=${1:?}
    declare ts=$2

    if [[ -z $ts ]]; then
        ts=$(xsh /date/timestamp)
    fi

    declare year month day
    year=$(xsh /date/year "$ts")
    month=$(xsh /date/month "$ts")
    day=$(xsh /date/day "$ts")

    declare start_year=$year end_year=$((year + offset))
    if [[ $month -lt 2 || ($month -eq 2 && $day -lt 29) ]]; then
        # the day is < Feb 29
        if [[ $offset -gt 0 ]]; then
            # forward, don't calculate the end year
            ((end_year++))
        elif [[ $offset -lt 0 ]]; then
            # backward, don't calculate the start year
            ((start_year--))
        fi
    else
        # the day is >= Feb 29
        if [[ $offset -gt 0 ]]; then
            # forward, don't calculate the start year
            ((start_year--))
        elif [[ $offset -lt 0 ]]; then
            # backward, don't calculate the end year
            ((end_year++))
        fi
    fi

    declare cnt=0
    for year in $(seq "$start_year" "$end_year"); do
        if xsh /date/leap/year/is "$year"; then
            ((cnt++))
        fi
    done
    echo "$cnt"
}
