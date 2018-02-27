#? Usage:
#?   @parser [-t DELIMITER | -e [-p PREFIX]] CSV_FILE
#?
#? Options:
#?   [-t DELIMITER]  Delimiter to be used as output field separator.
#?                   Default is '|'.
#?
#?   [-e]            Output result in the syntax of shell environment
#?                   variables.
#?
#?   [-p PREFIX]     Prefix variable name with PREFIX.
#?                   Default is '__CSV_'.
#?
#?   CSV_FILE        Full path of CSV file to parse.
#?                   Separated by commas, enclosured by double quote,
#?                   and first line as header.
#?
#? Output:
#?   The parsed result or shell variables.
#?
#? Desription:
#?   Parse a CSV file.
#?   Link: https://en.wikipedia.org/wiki/Comma-separated_values
#?
#?   If -e, Below variables are set after CSV file is parsed.
#?     __CSV_FIELDS: Array, variable name suffix for all fields.
#?     __CSV_FIELDS_<field>: Field name for <field>.
#?     __CSV_FIELDS_<field>_ROWS: Array, each row of <fields>.
#?
#? Example:
#?   foo.csv
#?     Year,Make,Model,Description,Price
#?     1997,Ford,E350,"ac, abs, moon",3000.00
#?     1999,Chevy,"Venture ""Extended Edition""","",4900.00
#?     1999,Chevy,"Venture ""Extended Edition, Very Large""",,5000.00
#?     1996,Jeep,Grand Cherokee,"MUST SELL!
#?     air, moon roof, loaded",4799.00
#?
#?   @parser foo.csv
#?   # Following variables were set:
#?
function parser () {
    local opt OPTIND OPTARG
    local base_dir display_separator action prefix csv_file
    local SEPARATOR=',' ENCLOSURE='"'

    action='display'
    base_dir=$(cd "$(dirname "$0")" && pwd)

    while getopts t:ep: opt; do
        case ${opt} in
            t)
                display_separator=${OPTARG}
                ;;
            e)
                action=setenv
                ;;
            p)
                prefix=${OPTARG}
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))
    csv_file=$1

    if [[ -z ${csv_file} ]]; then
        printf "ERROR: parameter 'CSV_FILE' null or not set.\n" >&2
        return 255
    fi

    if [[ ${action} == 'display' ]]; then
        awk -v separator=${SEPARATOR} \
            -v enclosure=${ENCLOSURE} \
            -v output_separator=${output_separator:-|} \
            -f "${base_dir}/parser.awk" \
            "${csv_file}"
    elif [[ ${action} == 'setenv' ]]; then
        source /dev/stdin <<< "$(
            awk -v separator=${SEPARATOR} \
                -v enclosure=${ENCLOSURE} \
                -v prefix=${prefix:-__CSV_} \
                '{csv_parse_and_setenv(separator, enclosure, prefix)}' \
                "${csv_file}"
        )"
    else
        printf "ERROR: unsupported action '%s'.\n" "${action}" >&2
        return 255
    fi
}
