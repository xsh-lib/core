#? Description:
#?   Get a timestamp with default format: "+%Y-%m-%d %H:%M:%S"
#?
#? Usage:
#?   @timestamp [-i | -m | -n] [+OUTPUT_FMT]
#?
#? Options:
#?   [-i]            Suffix .<millisecond> after the timestamp.
#?   [-m]            Suffix .<microsecond> after the timestamp.
#?   [-n]            Suffix .<nanosecond> after the timestamp.
#?   [+OUTPUT_FMT]   Date format string.
#?
function timestamp () {
    local OPTIND OPTARG opt

    local suffix nano_delta
    while getopts imn opt; do
        case $opt in
            i)
                suffix=1
                nano_delta='??????'
                ;;
            m)
                suffix=1
                nano_delta='???'
                ;;
            n)
                suffix=1
                nano_delta=
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))
    local fmt=${1:-${XSH_X_DATE__DATETIME_FMT:?}}

    if [[ -n $suffix ]]; then
        if xsh /date/is-compitable-date-N; then
            fmt=${fmt}.%N
        else
            printf "$FUNCNAME: ERROR: Command 'date' doesn't support format: %s.\n" "+%N" >&2
            return 255
        fi

        local ts=$(date "${fmt}")

        # remove the surplus precision from the end
        echo "${ts%${nano_delta}}"
    else
        date "${fmt}"
    fi
}
