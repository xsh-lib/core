#? Description:
#?   Convert the given timestamp to the given format.
#?
#? Usage:
#?   @convert [-f INPUT_FMT] <TIMESTAMP> <+OUTPUT_FMT>
#?
#? Options:
#?   [-f INPUT_FMT]
#?
#?   Specify the format of input TIMESTAMP.
#?
#?   This option is used for BSD date(macOS default), and is ignored for GNU date.
#?   If omitted, a native parser is used to parse the format of input TIMESTAMP.
#?   Check detail: `xsh help /date/parser`.
#?
#?   <TIMESTAMP>
#?
#?   Input timestamp.
#?
#?   <+OUTPUT_FMT>
#?
#?   Output format.
#?
function convert () {
    local OPTIND OPTARG opt

    local input_fmt
    while getopts f opt; do
        case $opt in
            f)
                input_fmt=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    local ts=${1:?}
    local output_fmt=${2:?}

    if xsh /date/is-compitable-date-d; then
        # for GNU date
        date -d "$ts" "$output_fmt"
    elif xsh /date/is-compitable-date-j; then
        # for BSD data (macOS default)
        if [[ -z $input_fmt ]]; then
            input_fmt=$(xsh /date/parser "$ts")
        fi

        if [[ -z $input_fmt ]]; then
            printf "$FUNCNAME: ERROR: Unable to parse format for '%s', please use '-f INPUT_FMT'.\n" "$ts" >&2
            return 255
        fi

        date -j -f "$input_fmt" "$ts" "$output_fmt"
    else
        printf "$FUNCNAME: ERROR: Not found the capable date util.\n" >&2
        return 255
    fi
}
