#? Description:
#?   An RPN expression calculator work with sets.
#?
#?   RPN: https://en.wikipedia.org/wiki/Reverse_Polish_notation
#?
#? Usage:
#?   @rpncalc EXPR ...
#?
#? Options:
#?   EXPR   The RPN expression.
#?
#? Example:
#?   $ @rpncalc '1 2 3' '2 3 4' \&
#?   2
#?   3
#?
function rpncalc () {

    function __is_comparator () {
        while read -r ln; do
            test "$1" == "$ln" && return 0 || :
        done <<< "$(x-int-set-op-comparator | xargs -n1)"
        return 255
    }

    declare -a STACK

    xsh imports /int/set/op-comparator /int/set/set

    declare o1 o2
    while [[ $# -gt 0 ]]; do
        if __is_comparator "$1"; then
            # IS OPERATORS
            o1=${STACK[@]:(-1)}
            unset STACK[$((${#STACK[@]} - 1))]
            o2=${STACK[@]:(-1)}
            unset STACK[$((${#STACK[@]} - 1))]

            STACK+=( "$(x-int-set-set "$o1" "$1" "$o2")" )
        else
            # IS OPERANDS
            STACK+=( "$1" )
        fi
        shift
    done

    unset -f __is_comparator
    echo "$STACK"
}
