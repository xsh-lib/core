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
    declare OPTIND OPTARG opt

    declare input_fmt
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

    declare ts=${1:?}
    declare output_fmt=${2:?}

    if xsh /date/is-compatible-date-d; then
        # for GNU date
        date -d "$ts" "$output_fmt"
    elif xsh /date/is-compatible-date-j; then
        # for BSD data (macOS default)
        if [[ -z $input_fmt ]]; then
            input_fmt=$(xsh /date/parser "$ts")
        fi

        if [[ -z $input_fmt ]]; then
            xsh log error "$ts: unable to parse format, please use '-f <INPUT_FMT>'."
            return 255
        fi

        date -j -f "$input_fmt" "$ts" "$output_fmt"
    else
        xsh log error "not found the capable date util."
        return 255
    fi
}
