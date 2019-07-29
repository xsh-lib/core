#? Description:
#?   A pseudo SQL interpreter for Bash.
#?   Using UNIX text files instead of RDBMS tables as the data store.
#?   By default, the field delimiter for input is whitespace ' ',
#?   the field delimiter for output is '\t'.
#?   The row delimiter is new line for both input and output.
#?
#? Return:
#?   0: succeed
#?   255: error
#?   100: 0 row selected
#?
#? Export:
#?   Q_TABLE: always set
#?   Q_FIELDS: always set
#?   Q_ROW_COUNT: always set
#?
#? Output:
#?   Query result.
#?
#? Examples:
#?   @Q select f1 f2 f3 from A
#?
#? Usage:
#?   @Q [OPTIONS] SELECT-CLAUSE FROM-CLAUSE \
#?       [WHERE-CLAUSE]
#?
#? Options:
#?   [OPTIONS]
#?     [-F] FS
#?
#?     Specify the FS used internally in Q, default is ''.
#?
#?     [-I] FS
#?
#?     Specify the input FS, will be used to process table,
#?     default is whitespace ' '.
#?
#?     [-O] FS
#?
#?     Specify the output FS, will be used to output result,
#?     default is '\t'.
#?
#?     [-H]
#?
#?     Show the table header in the reuslt output if specified.
#?
#?   SELECT-CLAUSE
#?     [distinct] [*] [FIELDS]
#?
#?   FROM-CLAUSE
#?     from TABLE-NAME
#?
#?   [WHERE-CLAUSE]
#?     where SEARCH-CONDITION
#?
#?     SEARCH-CONDITION
#?
#?   [ORDER-BY-CLAUSE]
#?     order by FIELD [asc | desc]
#?
function Q () {
    xsh import /array/append /string/lower '/util/*' '/sql/*' /csv/parser

    # Set default Field Separator (FS)
    local Q_FS=''     # Internal FS
    local Q_IFS=$' '    # Input FS
    local Q_OFS=$'\t'   # Output FS

    local OPTIND OPTARG opt
    local header=0

    while getopts F:I:O:H opt; do
        case $opt in
            F)
                Q_FS=$OPTARG
                ;;
            I)
                Q_IFS=$OPTARG
                ;;
            O)
                Q_OFS=$OPTARG
                ;;
            H)
                header=1
                ;;
            *)
                break
                ;;
        esac
    done
    shift $((OPTIND - 1))

    local RESERVED_KEYWORDS OPERATORS

    RESERVED_KEYWORDS=(
        "select"
        #"distinct"
        "from"
        #"where"
        #"and"
        #"or"
        #"order"
        #"by"
        #"asc"
        #"desc"
    )

    OPERATORS=(
        [0]="like"
        [1]="="
        [2]="!="
        [3]=">"
        [4]="<"
        [5]=">="
        [6]="<="
    )

    # Parsing SQL

    x-sql-parser "$@" || return

    if [[ ! -f $Q_TABLE ]]; then
        return 255
    fi

    # Parsing table data into array

    x-csv-parser -I "$Q_IFS" -e -a -p 'Q_' "$Q_TABLE"

    # Process predcates
    declare -a candidate_row_indeces

    # Select all rows
    if [[ $header -eq 0 ]]; then
        # Surprise table header
        candidate_row_indeces=( $(seq 1 "$((Q_NR-1))") )
    else
        candidate_row_indeces=( $(seq 0 "$((Q_NR-1))") )
    fi

    Q_ROW_COUNT=${#candidate_row_indeces[@]}

    if [[ $Q_ROW_COUNT -eq 0 ]]; then
        # No rows returned
        return 100
    fi

    # Build record set
    local row_index
    for row_index in ${candidate_row_indeces[@]}; do
        local i=0 qf_name ln
        for qf_name in "${Q_SELECTED_FIELDS[@]}"; do
            if [[ $i -gt 0 ]]; then
                printf "%s" "$Q_OFS"
            fi
            local varname="Q_FIELDS_${qf_name}_ROWS[$row_index]"
            printf "%s" "${!varname}"
            i=$((i+1))
        done
        echo
    done

    return 0
}
