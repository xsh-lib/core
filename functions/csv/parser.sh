#? Usage:
#?   @parser [-t DELIMITER] CSV_FILE
#?   @parser -e [-a] [-p PREFIX] [-q] [-s] CSV_FILE
#?
#? Options:
#?   [-t DELIMITER]  Delimiter to be used as output field separator.
#?                   Default is '|'.
#?
#?   [-e]            Output result in the syntax of shell environment
#?                   variables rather than the table.
#?
#?   [-a]            Apply the environment variables.
#?                   With -a enabled, -s and -q are ignored.
#?
#?   [-p PREFIX]     Prefix variable name with PREFIX.
#?                   Default is '__CSV_'.
#?
#?   [-q]            Enable quotes, value will be quoted.
#?
#?   [-s]            Enable signle mode, generate single expression for array assignment.
#?
#?   CSV_FILE        Full path of CSV file to parse.
#?                   Separated by commas, quoted between double quotes,
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
#?   # Year|Make|Model|Description|Price
#?   # 1997|Ford|E350|ac, abs, moon|3000.00
#?   # 1999|Chevy|Venture "Extended Edition"||4900.00
#?   # 1999|Chevy|Venture "Extended Edition, Very Large"||5000.00
#?   # 1996|Jeep|Grand Cherokee|MUST SELL!air, moon roof, loaded|4799.00
#?
#?   @parser -e -q -s foo.csv
#?   # Following variables were set:
#?   # __CSV_FIELDS=([1]="Year" [2]="Make" [3]="Model" [4]="Description" [5]="Price")
#?   # __CSV_FIELDS_Description=Description
#?   # __CSV_FIELDS_Description_ROWS=([1]="Description" [2]="ac, abs, moon" [3]="" [4]="" [5]="MUST SELL!air, moon roof, loaded")
#?   # __CSV_FIELDS_Make=Make
#?   # __CSV_FIELDS_Make_ROWS=([1]="Make" [2]="Ford" [3]="Chevy" [4]="Chevy" [5]="Jeep")
#?   # __CSV_FIELDS_Model=Model
#?   # __CSV_FIELDS_Model_ROWS=([1]="Model" [2]="E350" [3]="Venture \"Extended Edition\"" [4]="Venture \"Extended Edition, Very Large\"" [5]="Grand Cherokee")
#?   # __CSV_FIELDS_Price=Price
#?   # __CSV_FIELDS_Price_ROWS=([1]="Price" [2]="3000.00" [3]="4900.00" [4]="5000.00" [5]="4799.00")
#?   # __CSV_FIELDS_Year=Year
#?   # __CSV_FIELDS_Year_ROWS=([1]="Year" [2]="1997" [3]="1999" [4]="1999" [5]="1996")
#?
function parser () {
    local opt OPTIND OPTARG
    local table_separator output apply prefix quote single csv_file
    local ln
    local SEPARATOR=',' BETWEEN='"'
    local BASE_DIR="${XSH_HOME}/lib/x/functions/csv"  # TODO: use varaible instead

    output='table'

    while getopts t:eap:qs opt; do
        case ${opt} in
            t)
                table_separator=${OPTARG}
                ;;
            e)
                output=variable
                ;;
            a)
                apply=1
                ;;
            p)
                prefix=${OPTARG}
                ;;
            q)
                quote=1
                ;;
            s)
                single=1
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

    prefix=${prefix:-__CSV_}

    if [[ ${output} == 'table' ]]; then
        awk -v separator=${SEPARATOR} \
            -v between=${BETWEEN} \
            -v output=${output} \
            -v table_separator="${table_separator:-|}" \
            -f "${BASE_DIR}/parser.awk" \
            "${csv_file}"
    elif [[ ${output} == 'variable' ]]; then
        if [[ ${apply} ]]; then
            while read ln; do
                xsh /string/global "${ln}"
            done <<< "$(
                 awk -v separator=${SEPARATOR} \
                     -v between=${BETWEEN} \
                     -v output=${output} \
                     -v prefix="${prefix}" \
                     -f "${BASE_DIR}/parser.awk" \
                     "${csv_file}"
                 )"
        else
            awk -v separator=${SEPARATOR} \
                -v between=${BETWEEN} \
                -v output=${output} \
                -v prefix="${prefix}" \
                -v quote="${quote}" \
                -v single="${single}" \
                -f "${BASE_DIR}/parser.awk" \
                "${csv_file}"
        fi
    else
        printf "ERROR: unsupported output '%s'.\n" "${output}" >&2
        return 255
    fi
}
