function select ()
{
    # IFS: Input FS
    # OFS: Output FS
    # XFS: xsql internal FS
    local IFS OFS XFS
    local __RESERVED_KEYWORDS __OPERATORS

    [[ -z ${IFS} ]] && IFS='|'
    [[ -z ${OFS} ]] && OFS='\t\t'
    [[ -z ${XFS} ]] && XFS=''

    __RESERVED_KEYWORDS=(
        [0]="distinct"
        [1]="count"
        #[2]="max"
        #[3]="min"
        [4]="from"
        [5]="where"
        [6]="and"
        [7]="or"
        #[8]="order by"
        #[9]="asc"
        #[10]="desc"
    )

    __OPERATORS=(
        [0]="like"
        [1]="=="
        [2]="!="
        [3]=">"
        [4]="<"
        [5]=">="
        [6]="<="
    )

    # main begin

    validate ()
    {
        echo "$@"
    }


    local __querycols __queryfile __predicates

    parse ()
    {
        local __part="querycols"
        while [[ $# -gt 0 ]]; do
            case $1 in
                from)
                    __part="queryfile"
                    ;;
                where)
                    __part="predicates"
                    ;;
                *)
                    case ${__part} in
                        querycols)
                            __querycols[$(xarr.inext __querycols)]=$1
                            ;;
                        queryfile)
                            __queryfile=$1
                            ;;
                        predicates)
                            __predicates[$(xarr.inext __predicates)]=$1
                    esac
                    ;;
            esac
            shift
        done
    }


    validate "$@"
    parse "$@"

    echo ${__querycols[@]}
    echo ${__queryfile[@]}
    echo ${__predicates[@]}

    [[ -z ${__querycols} || -z ${__queryfile} ]] && return 1

    # Parsing select list into array
    if [[ ${__querycols:1:6} == 'count(' ]] ; then
        local __count=1
        __querycols=$(echo ${__querycols} |sed 's/^count(//' |sed 's/)$//')
    fi

    if [[ ${__querycols:1:8} == 'distinct' ]] ; then
        local __distinct=1
        __querycols=$(echo ${__querycols} |sed 's/^distinct//')
    fi
    __querycols=( $(echo "${__querycols[@]}" |sed 's/,/ /g') )


    local __tmpfile=/tmp/$$

    # Remove the null lines
    # Lines leading with '#' is commented
    # Replace all IFS to XFS, use \IFS to escape a real IFS, exam: \| is a character, not a delimiter
    # Replace all \IFS to IFS after last step
    # Remove the leading and trailing blank space for each line
    # Remove the leading and trailing blank space for each column

    awk NF ${__queryfile} | awk '!/^#/' | sed -r "s/([^\\])\\${IFS}/\1${XFS}/g" | sed "s/[\\]${IFS}/${IFS}/g" | sed -r 's/^[ \t]+|[ \t]+$|//g' | sed -r "s/[ \t]*($XFS)[ \t]*/\1/g" > $tmp

    ROW_COUNT=$(awk 'END {debug NR - 1}' $tmp)

    # Parsing table columns name into array
    local arr_cols=($(head -1 $tmp |sed "s/$FFS/ /g"))

    # Initial variable
    debug "initial variable"
    for x in ${arr_cols[@]}; do
        eval "local $prefix$x"
    done

    # Parsing all columns of the table into an array named as $prefix + the column name
    # the first value of each array (arrar[0]) is the column header
    debug "parsing all columns of the table into an array named as $prefix + the column name"
    i=1
    for x in ${arr_cols[@]}; do
        # Don't know why the former doesn't work
        #eval $prefix$x=\($(cut -d$FFS -f$i $tmp |sed -r "s/^\|$/'/g")\)
        eval $prefix$x=\($(cut -d$FFS -f$i $tmp |sed "s/^/'/" |sed "s/$/'/")\)
        let i++
    done

    [[ ${arr_qrycols[@]} = '1' ]] && arr_qrycols=("${arr_cols[@]}")

    # Initial return array variables by select list
    debug "initial return variable"
    if [[ count_flag -eq 1 ]] ; then
        unset count
    else
        for x in ${arr_qrycols[@]}; do
            eval unset $x
        done
    fi

    debug "process predcates"
    local arr_fav
    if [[ -z $preds ]] ; then
        # Select all rows
        arr_fav=($(seq $ROW_COUNT))
    else
        # Apply the WHERE clause
        local arr_preds=($(echo $preds))
        local pred conj last_conj pos len col_name col_value fav arr_col

        i=0
        for x in ${arr_preds[@]}; do
            [[ -n $conj ]] && last_conj=$conj
            [[ ${arr_fav[0]} = '-1' && $conj = 'and' ]] && unset arr_fav && break

            if [[ $(($i % 2)) -eq 0 ]] ; then

                # Process each predicate
                debug "process each predicate: $x"
                debug "decide the mark length"
                pos=$(expr index $x '=!~<>')
                if [[ $(expr index "$(echo $x |cut -c$(($pos + 1)))" '=>') -gt 0 ]] ; then
                    len=2
                else
                    len=1
                fi

                debug "get the pair and mark"
                if [[ $pos -ne 0 ]] ; then
                    col_name=$(expr substr $x 1 $(($pos - 1)))
                    pred=$(expr substr $x $pos $len)
                    col_value=$(expr substr $x $(($pos + $len)) 999)
                else
                    return 1
                fi

                # Apply the predicate to filter rows in the table
                debug "filter rows by predicate"
                eval arr_col=(\"\${$prefix$col_name[@]}\")

                unset fav
                j=1
                for y in "${arr_col[@]:1}"
                do
                    case $pred in
                        \=)
                            [[ $y = $col_value ]] && fav="$fav $j"
                            ;;
                        \!=|\<\>)
                            [[ $y != $col_value ]] && fav="$fav $j"
                            ;;
                        \>=)
                        [[ $y -ge $col_value ]] && fav="$fav $j"
                        ;;
                        \<=)
                        [[ $y -le $col_value ]] && fav="$fav $j"
                        ;;
                        \>)
                            [[ $y -gt $col_value ]] && fav="$fav $j"
                            ;;
                        \<)
                            [[ $y -lt $col_value ]] && fav="$fav $j"
                            ;;
                        \~=)
                        [[ $(expr match "$y" ".*${col_value}.*") -gt 0 ]] && fav="$fav $j"
                    esac

                    let j++
                done

                [[ -z $fav ]] && fav=-1
                [[ -z $arr_fav ]] && arr_fav[0]="$fav" || arr_fav[1]="$fav"

                if [[ $last_conj = 'and' ]] ; then
                    arr_fav[0]="$(echo ${arr_fav[@]} |xargs -n1 |duplicate)"
                    unset arr_fav[1]
                elif [[ $last_conj = 'or' ]] ; then
                    arr_fav[0]="$(echo ${arr_fav[@]} |xargs -n1 |distinct)"
                    unset arr_fav[1]
                fi
            else
                # Decide AND OR
                debug "decide AND OR"
                case $x in
                    and|or)
                        conj=$x
                        # Do not allow mixed AND and OR
                        #[[ $conj != $last_conj ]] && return 1
                        ;;
                    *)
                        return 1
                esac
            fi

            [[ ${arr_fav[1]} = '-1' && $last_conj = 'and' ]] && unset arr_fav && break

            let i++
        done

        debug "process all predicates done"
        arr_fav=($(echo $arr_fav |sed 's/-1//'))
    fi

    # None rows returned
    [[ -z ${arr_fav[@]} ]] && return 100

    # Count(1) none distinct
    if [[ $count_flag -eq 1 && $merge_flag -ne 1 ]] ; then
        count=${#arr_fav[@]}
        ROW=($count)
        ROW_COUNT=${#ROW[@]}
        echo $ROW

        return 0
    fi

    eval local row_tmp=$xsh_tmp_file.row

    # Build record set
    i=0
    for x in ${arr_fav[@]}; do
        unset ln
        j=0
        for y in ${arr_qrycols[@]}; do
            eval ln="\$ln$([[ $j -gt 0 ]] && echo $FFS)\"\${$prefix$y[$x]}\""
            let j++
        done
        echo $ln >> $row_tmp

        let i++
    done

    # Distinct
    if [[ $merge_flag -eq 1 ]] ; then
        # Merge duplicate, inconsecutive lines as one
        # Do not break the original sequence
        distinct $row_tmp > $tmp
        cp $tmp $row_tmp
    fi

    # Order by
    if [[ $sorts = 'asc' ]] ; then
        cat $row_tmp |sort > $tmp
        cp $tmp $row_tmp
    elif [[ $sorts = 'desc' ]] ; then
        cat $row_tmp |sort -r > $tmp
        cp $tmp $row_tmp
    fi

    # Set global variable $ROW
    i=1
    for x in ${arr_qrycols[@]}; do
        #eval $x=\($(cut -d$FFS -f$i $row_tmp |sed -r "s/^\|$/'/g")\)
        eval $x=\($(cut -d$FFS -f$i $row_tmp |sed "s/^/'/" |sed "s/$/'/")\)
        let i++
    done
    ROW[${#ROW[@]}]=$ln

    # Count(1)
    if [[ $count_flag -eq 1 ]] ; then
        count=${#ROW[@]}
        ROW=($count)
    fi

    ROW_COUNT=${#ROW[@]}
    cat $row_tmp |sed "s/$FFS/$OFS/g"

    return 0
}
