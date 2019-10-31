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
    declare OPTIND OPTARG opt

    declare suffix nano_delta
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
    declare fmt=${1:-${XSH_X_DATE__DATETIME_FMT:?}}

    if [[ -n $suffix ]]; then
        if xsh /date/is-compatible-date-N; then
            fmt=${fmt}.%N
        else
            xsh log error "+%N: the format is not supported by date."
            return 255
        fi

        declare ts=$(date "${fmt}")

        # remove the surplus precision from the end
        echo "${ts%${nano_delta}}"
    else
        date "${fmt}"
    fi
}
