#? Description:
#?   Adjust the second, minute, hour, month day, week day, month or year
#?   according to value.
#?
#?   If value is preceded with a plus or minus sign, the date is adjusted
#?   forwards or backwards according to the remaining string, otherwise
#?   the relevant part of the date is set.
#?
#?   The date can be adjusted as many times as required using these flags.
#?
#?   Works with with "date -v" from Mac OS X and "data -d" from Linux.
#?
#? Usage:
#?   @adjust [+-][<VALUE>[ymwdHMS] | monday | tuesday | ...] [...]
#?           <TIMESTAMP>
#?
#? Example:
#?   @adjust +21d 2008-10-10
#?   2008-10-31
#?
#?   @adjust -1y 2008-10-10
#?   2007-10-10
#?
#?   @adjust +30M +30S "2008-10-10 00:00:00"
#?   2008-10-10 00:30:30
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
