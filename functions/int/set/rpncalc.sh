#? Description:
#?   An RPN expression calculator work with sets.
#?
#? Usage:
#?   @rpncalc SET OPERATOR SET [OPERATOR SET] ...
#?
#? Options:
#?   SET
#?
#?   The set is a string contains sorted elements delimited by whitespace or newline.
#?
#?   OPERAND
#?
#?   &
#?   |
#?
#? Example:
#?
function rpncalc () {
    declare -a STACK

    xsh import /int/set/op-comparator /int/set/set

    function __is_comparator () {
        while read -r ln; do
            test "$1" == "$ln" && return 0 || :
        done < <(x-int-set-op-comparator | xargs -n1)
        return 255
    }

    local o1 o2
    while [[ $# -gt 0 ]]; do
        if __is_comparator "$1"; then
            # IS OPERATORS
            o1="${STACK[@]:(-1)}"
            unset STACK[$((${#STACK[@]} - 1))]
            o2="${STACK[@]:(-1)}"
            unset STACK[$((${#STACK[@]} - 1))]

            STACK[${#STACK[@]}]="$(x-int-set-set "$o1" "$1" "$o2")"
        else
            # IS OPERANDS
            STACK[${#STACK[@]}]=$1
        fi
        shift
    done

    unset -f __is_comparator
    echo "$STACK"
}
