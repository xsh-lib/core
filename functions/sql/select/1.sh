#? Description:
#?   A pseudo SQL interpreter for Bash.
#?   Using UNIX text files instead of RDBMS tables as the data store.
#?   By default, the field delimiter is '|', and the row delimiter is
# ?  new line for the text files.
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
#?   @select select f1 f2 f3 from A
#?
#? Usage:
#?   @select SELECT-CLAUSE FROM-CLAUSE \
#?          [WHERE-CLAUSE] \
#?
#? Options:
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
#?
function select () {
    xsh import /array/append /string/lower '/util/*' '/sql/*'

    local Q_FS Q_IFS Q_OFS

    # Q_FS: SQL Internal Field Separator
    Q_FS=${Q_FS:-}

    # Q_IFS: SQL Input Field Separator
    Q_IFS=${Q_IFS:- } # whitespace

    # Q_OFS: SQL Output Field Separator
    Q_OFS=${Q_OFS:- } # tab

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

    # main begin

    x-sql-parse "$@" || return

    if [[ ! -f $Q_TABLE ]]; then
        return 255
    fi

    local tmp_table=/tmp/Q-$$-$RANDOM

    # Remove the null lines
    # Lines leading with '#' is commented
    # Replace all Q_IFS to Q_FS, use \Q_IFS to escape a real Q_IFS, exam: \| is a character, not a delimiter
    # Replace all \Q_IFS to Q_IFS after last step
    # Remove the leading and trailing blank space for each line
    # Remove the leading and trailing blank space for each column

    awk NF "${Q_TABLE}" \
        | awk '!/^#/' \
        | x-util-sed-regex \
        | x-util-sed-regex "s/([^\\])\\${Q_IFS}/\1${Q_FS}/g" \
        | sed "s/[\\]${Q_IFS}/${Q_IFS}/g" \
        | x-util-sed-regex 's/^[ \t]+|[ \t]+$//g' \
        | x-util-sed-regex "s/[ \t]*($Q_FS)[ \t]*/\1/g" \
                           > $tmp_table

    row_count=$(awk 'END {printf NR - 1}' $tmp_table)

    # Parsing table columns name into array
    local tab_fields
    IFS=$Q_FS read -r -a tab_fields <<< "$(head -1 $tmp_table)"

    local tab_field_var_prefix='rows_of_'

    # Unset all table field variables
    local tf_name
    for tf_name in ${tab_fields[@]}; do
        declare -a "$tab_field_var_prefix$tf_name"
    done

    # Populate all the values of table column into an array named as
    # <tab_field_var_prefix><field_name>, column name is at index 0
    # of each array.
    local i=1 ln
    for tf_name in ${tab_fields[@]}; do
        while read ln; do
            x-array-append "$tab_field_var_prefix$tf_name" "$ln"
        done <<< "$(cut -d "$Q_FS" -f$i $tmp_table)"
        let i++
    done
    /bin/rm -f "$tmp_table"

    local query_field_var_prefix='q_rows_of_'

    # initiate all query field variables
    local qf_name
    for qf_name in "${Q_FIELDS[@]}"; do
        declare -a "$query_field_var_prefix$qf_name"
    done

    # Process predcates
    local candidate_row_indeces
    # Select all rows
    candidate_row_indeces=( $(seq 0 $row_count) )

    Q_ROW_COUNT=${#candidate_row_indeces[@]}

    if [[ $Q_ROW_COUNT -eq 0 ]]; then
        # No rows returned
        return 100
    fi

    # Build record set
    local row_index
    for row_index in ${candidate_row_indeces[@]}; do
        local i=0 qf_name ln
        for qf_name in ${Q_FIELDS[@]}; do
            if [[ $i -gt 0 ]]; then
                printf "%s" "$Q_OFS"
            fi
            local varname="${tab_field_var_prefix}${qf_name}[$row_index]"
            printf "%s" "${!varname}"
            i=$((i+1))
        done
        echo
    done

    return 0
}
