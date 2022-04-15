#? Description:
#?   Evaluate set expression.
#?
#? Usage:
#?   @eval EXPR
#?
#? Options:
#?   EXPR
#?
#?   The expression to evaluate.
#?
#? Example:
#?   $ @eval '1 2 3 4 & (2 3 4 5 | 3 4 5 6)'
#?   2
#?   3
#?   4
#?
function eval () {
    declare -a RPN

    declare ln
    while read -r ln; do
        RPN+=( "$ln" )
    done <<< "$(xsh /math/infix2rpn -c 'xsh /int/set/op-comparator' -d '\n' "$*")"

    xsh /int/set/rpncalc "${RPN[@]}"
}
