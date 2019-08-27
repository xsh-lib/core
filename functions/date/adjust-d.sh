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
#?   Works with "date -d" from Linux.
#?
#? Usage:
#?   @adjust-d <TIMESTAMP>
#?             [[+-]<VALUE> [year | month | week | day | hour | minute | second]] [...]
#?             [last | next]-[monday | tuesday | ...] [...]
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
    local datetime=$1
    shift

    local adjust=$1
    shift

    local fmt=$(xsh /date/parser "${datetime}")
    local keyword=${adjust%%-*} # last|next

    local result
    case $keyword in
        last|next)
            local adjust_week_name=${adjust##*-} # monday|tuesday|wednesday|thursday|saturday|sunday
            local adjust_week_index=$(date -d $adjust_week_name +%u) # 1|2|3|4|5|6|7
            local week_index=$(date -d "${datetime}" +%u) # 1|2|3|4|5|6|7

            local diff_days
            if [[ $keyword == last ]]; then
                diff_days=$((week_index - adjust_week_index))
            elif [[ $key_word == next ]]; then
                diff_days=$((adjust_week_index - week_index))
            fi

            if [[ $diff_days -lt 0 ]]; then
                diff_days=$((diff_days + 7))
            fi

            if [[ $diff_days -eq 0 ]]; then
                result=$datetime # No need to adjust
            else
                result=$(xsh /date/adjust-d "${datetime}" "-$diff_days day")
            fi
            ;;
        *)
            result="$(date -d "${datetime} $adjust" "+${fmt}")"
            ;;
    esac

    if [[ -n $@ ]]; then
        # Call recursively to get result
        result="$(xsh /date/adjust-d "$result" "$@")"
    else
        : # No more adjusts
    fi

    echo "$result"
}
