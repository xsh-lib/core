#? Usage:
#?   @search [-o OPERAND] ARRAY EXPR
#?
#? Options:
#?   [-o OPERAND]
#?
#?   The operand used for the search. Default operand is '='.
#?   Supported operands:
#?     =       True if the strings s1 and s2 are identical.
#?
#?     !=      True if the strings s1 and s2 are not identical.
#?
#?     <       True if string s1 comes before s2 based on the binary value of their characters.
#?
#?     >       True if string s1 comes after s2 based on the binary value of their characters.
#?
#?     -eq     True if the integers n1 and n2 are algebraically equal.
#?
#?     -ne     True if the integers n1 and n2 are not algebraically equal.
#?
#?     -gt     True if the integer n1 is algebraically greater than the integer n2.
#?
#?     -ge     True if the integer n1 is algebraically greater than or equal to the integer n2.
#?
#?     -lt     True if the integer n1 is algebraically less than the integer n2.
#?
#?     -le     True if the integer n1 is algebraically less than or equal to the integer n2.
#?
#?   ARRAY
#?
#?   Array name the search is performed with.
#?
#?   EXPR
#?
#?   Expression to search on the array.
#?
#? Output:
#?   The index of all matching elements in the array.
#?
#? Example:
#?   $ arr=([3]="III" [4]="IV" [5]="V"); @search -o '!=' arr 'V'
#?   3
#?   4
#?
function search () {
    declare OPTIND OPTARG

    declare __opt __operand='='
    while getopts o: __opt; do
        case $__opt in
            o)
                __operand=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ -z $1 ]]; then
        printf "ERROR: Array name is null or not set.\n" >&2
        return 255
    fi

    declare __i __arr_i
    for __i in $(xsh /array/index "$1"); do
        __arr_i="$1[__i]"

        # shellcheck disable=SC2015
        test "${!__arr_i}" "$__operand" "$2" && echo "$__i" || :
    done
}
