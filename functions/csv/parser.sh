#? Desription:
#?   Parse a CSV file.
#?
#?   If set -a, Below variables are set after CSV file is parsed.
#?     __CSV_FIELDS: Array, variable name suffix for all fields.
#?     __CSV_FIELDS_<field>: Field name for <field>.
#?     __CSV_FIELDS_<field>_ROWS: Array, each row of <fields>.
#?     __CSV_NR: Number of rows in CSV.
#?
#?   This util is inspired by the repo:
#?     https://github.com/geoffroy-aubry/awk-csv-parser
#?     which is written by: Geoffroy Aubry, geoffroy.aubry.pro@gmail.com
#?
#? Usage:
#?   @parser [-I DELIMITER] [-O DELIMITER] CSV_FILE
#?   @parser -e [-I DELIMITER] [-a] [-p PREFIX] [-q] [-s] CSV_FILE
#?
#? Options:
#?   [-I DELIMITER]  Delimiter to be used as input field separator.
#?                   Default is ','.
#?
#?   [-O DELIMITER]  Delimiter to be used as output field separator.
#?                   Default is '|'.
#?
#?   [-e]            Output result in the syntax of shell environment
#?                   variables rather than the table.
#?
#?   [-a]            Apply the environment variables.
#?                   With -a enabled, output is turned off, and -s and -q are ignored.
#?
#?   [-p PREFIX]     Prefix variable name with PREFIX.
#?                   Default is '__CSV_'.
#?
#?   [-q]            Enable quotes in output, value will be quoted.
#?
#?   [-s]            Enable signle mode in output, generate single expression for array
#?                   assignment.
#?
#?   CSV_FILE        Full path of CSV file to parse.
#?                   Separated by commas(overriding with -I), quoted between double quotes,
#?                   and first line as header.
#?
#? Output:
#?   The parsed result or shell variables expression.
#?
#? Standard:
#?   https://en.wikipedia.org/wiki/Comma-separated_values
#?
#? Example:
#?   $ cat foo.csv
#?   Year,Make,Model,Description,Price
#?   1997,Ford,E350,"ac, abs, moon",3000.00
#?   1999,Chevy,"Venture ""Extended Edition""","",4900.00
#?   1999,Chevy,"Venture ""Extended Edition, Very Large""",,5000.00
#?   1996,Jeep,Grand Cherokee,"MUST SELL!
#?   air, moon roof, loaded",4799.00
#?
#?   $ @parser foo.csv
#?   Year|Make|Model|Description|Price
#?   1997|Ford|E350|ac, abs, moon|3000.00
#?   1999|Chevy|Venture "Extended Edition"||4900.00
#?   1999|Chevy|Venture "Extended Edition, Very Large"||5000.00
#?   1996|Jeep|Grand Cherokee|MUST SELL!air, moon roof, loaded|4799.00
#?
#?   $ @parser -e foo.csv
#?   __CSV_FIELDS=([0]="Year" [1]="Make" [2]="Model" [3]="Description" [4]="Price")
#?   __CSV_FIELDS_Description=Description
#?   __CSV_FIELDS_Description_ROWS=([0]="Description" [1]="ac, abs, moon" [2]="" [3]="" [4]="MUST SELL!air, moon roof, loaded")
#?   __CSV_FIELDS_Make=Make
#?   __CSV_FIELDS_Make_ROWS=([0]="Make" [1]="Ford" [2]="Chevy" [3]="Chevy" [4]="Jeep")
#?   __CSV_FIELDS_Model=Model
#?   __CSV_FIELDS_Model_ROWS=([0]="Model" [1]="E350" [2]="Venture \"Extended Edition\"" [3]="Venture \"Extended Edition, Very Large\"" [4]="Grand Cherokee")
#?   __CSV_FIELDS_Price=Price
#?   __CSV_FIELDS_Price_ROWS=([0]="Price" [1]="3000.00" [2]="4900.00" [3]="5000.00" [4]="4799.00")
#?   __CSV_FIELDS_Year=Year
#?   __CSV_FIELDS_Year_ROWS=([0]="Year" [1]="1997" [2]="1999" [3]="1999" [4]="1996")
#?
#?   $ @parser -a foo.csv; set | grep ^__CSV_
#?   __CSV_FIELDS=([0]="Year" [1]="Make" [2]="Model" [3]="Description" [4]="Price")
#?   __CSV_FIELDS_Description=Description
#?   __CSV_FIELDS_Description_ROWS=([0]="Description" [1]="ac, abs, moon" [2]="" [3]="" [4]="MUST SELL!air, moon roof, loaded")
#?   __CSV_FIELDS_Make=Make
#?   __CSV_FIELDS_Make_ROWS=([0]="Make" [1]="Ford" [2]="Chevy" [3]="Chevy" [4]="Jeep")
#?   __CSV_FIELDS_Model=Model
#?   __CSV_FIELDS_Model_ROWS=([0]="Model" [1]="E350" [2]="Venture \"Extended Edition\"" [3]="Venture \"Extended Edition, Very Large\"" [4]="Grand Cherokee")
#?   __CSV_FIELDS_Price=Price
#?   __CSV_FIELDS_Price_ROWS=([0]="Price" [1]="3000.00" [2]="4900.00" [3]="5000.00" [4]="4799.00")
#?   __CSV_FIELDS_Year=Year
#?   __CSV_FIELDS_Year_ROWS=([0]="Year" [1]="1997" [2]="1999" [3]="1999" [4]="1996")
#?   __CSV_NR=5
#?
function parser () {
    declare opt OPTIND OPTARG
    declare table_separator output apply prefix quote single csv_file
    declare ln
    declare SEPARATOR=',' BETWEEN='"'
    declare BASE_DIR=${XSH_HOME}/lib/x/functions/csv  # TODO: use varaible instead

    output='table'

    while getopts I:O:eap:qs opt; do
        case ${opt} in
            I)
                SEPARATOR=${OPTARG}
                ;;
            O)
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

    if [[ ${apply} ]]; then
        while read ln; do
            xsh /string/global "${ln}"
        done <<< "$(
             awk -v separator="${SEPARATOR}" \
                 -v between=${BETWEEN} \
                 -v output=variable \
                 -v prefix="${prefix}" \
                 -f "${BASE_DIR}/parser.awk" \
                 "${csv_file}"
             )"
    elif [[ ${output} == 'table' ]]; then
        awk -v separator="${SEPARATOR}" \
            -v between=${BETWEEN} \
            -v output=${output} \
            -v table_separator="${table_separator:-|}" \
            -f "${BASE_DIR}/parser.awk" \
            "${csv_file}"
    elif [[ ${output} == 'variable' ]]; then
        awk -v separator=${SEPARATOR} \
            -v between=${BETWEEN} \
            -v output=${output} \
            -v prefix="${prefix}" \
            -v quote="${quote}" \
            -v single="${single}" \
            -f "${BASE_DIR}/parser.awk" \
            "${csv_file}"
    else
        printf "ERROR: unsupported output '%s'.\n" "${output}" >&2
        return 255
    fi
}
