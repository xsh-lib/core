#? Description:
#?   A pseudo SQL interpreter for Bash.
#?   Using UNIX text files instead of RDBMS tables as the data store.
#?   By default, the field delimiter for input is whitespace ' ',
#?   the field delimiter for output is '\t'.
#?   The row delimiter is new line for both input and output.
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
#? Return:
#?   0: succeed
#?   255: error
#?   100: 0 row selected
#?
#? Export:
#?   Q_ROW_COUNT: always set
#?   Q_FIELDS_*:  always set
#?
#? Output:
#?   Query result without header.
#?
#? Examples:
#?   cat A
#?   # a b c
#?   # 1 4 7
#?   # 2 5 8
#?   # 3 6 9
#?
#?   @Q select a,b,c from A where a = 1 or b = 5
#?   # 1	4	7
#?   # 2	5	8
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
        "from"
        "where"
        "and"
        "or"
    )

    OPERATORS=(
        [1]="="
        [2]="!="
        [3]=">"
        [4]="<"
        [5]="-eq"
        [6]="-ne"
        [7]="-gt"
        [8]="-ge"
        [9]="-lt"
        [10]="-le"
    )

    # Parsing SQL

    local Q_SELECTED_FIELDS Q_TABLE Q_WHERE
    x-sql-parser "$@" || return

    if [[ ! -f $Q_TABLE ]]; then
        return 255
    fi

    # Parsing table data into array

    local Q_FIELDS Q_NR
    x-csv-parser -I "$Q_IFS" -e -a -p 'Q_' "$Q_TABLE"

    # Process where clause

    local selected_row_indeces

    if [[ ${#Q_WHERE[@]} -gt 0 ]]; then

        # Process predicates

        declare -a candidate_set

        # Always select header
        candidate_set[0]=0
        candidate_set[1]='|'

        local s_field  # search field
        local s_operator  # search operator

        local i=1 expr
        for expr in "${Q_WHERE[@]}"; do
            case $expr in
                '('|')')
                    candidate_set[${#candidate_set[@]}]=$expr
                    ;;
                *)
                    case $((i % 4)) in
                        1)  # key
                            s_field=$expr
                            ;;
                        2)  # operator
                            s_operator=$expr
                            ;;
                        3)  # value
                            candidate_set[${#candidate_set[@]}]="$(
                                xsh /array/search -o "$s_operator" "Q_FIELDS_${s_field}_ROWS" "$expr")"
                            ;;
                        0)  # and/or
                            case $expr in
                                and)
                                    candidate_set[${#candidate_set[@]}]='&'
                                    ;;
                                or)
                                    candidate_set[${#candidate_set[@]}]='|'
                                    ;;
                            esac
                            ;;
                    esac
                    i=$((i + 1))
                    ;;
            esac
        done

        # Calculate candidate sets expression
        selected_row_indeces=( $(xsh /int/set/eval "${candidate_set[@]}") )
    else
        selected_row_indeces=( $(seq 0 "$((Q_NR - 1))") )
    fi

    # Process table header

    if [[ $header -eq 0 ]]; then
        # Suppress table header
        unset selected_row_indeces[0]
    fi

    # Process row count

    Q_ROW_COUNT=$((${#selected_row_indeces[@]} - 1))
    if [[ $Q_ROW_COUNT -eq 0 ]]; then
        # No rows returned
        return 100
    fi

    # Build result record set

    local row_index
    for row_index in ${selected_row_indeces[@]}; do
        local i=0 qf_name ln
        for qf_name in "${Q_SELECTED_FIELDS[@]}"; do
            if [[ $i -gt 0 ]]; then
                printf "%s" "$Q_OFS"
            fi
            local varname="Q_FIELDS_${qf_name}_ROWS[$row_index]"
            printf "%s" "${!varname}"
            i=$((i + 1))
        done
        echo
    done

    return
}
