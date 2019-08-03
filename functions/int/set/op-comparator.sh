#? Description:
#?   Operators comparator, return the priority of 2 operators.
#?
#? Usage:
#?   @op-comparator [OPERATOR] [OPERATOR]
#?
#? Output:
#?   = 0: The two have equal priority.
#?   > 0: The former is higher than the later.
#?   < 0: The former is lower than the later.
#?
#? Example:
#?   @op-comparator '&' '|'
#?   # 1
#?
function op-comparator () {

    local OPERATORS=(
        [0]='|'
        [1]='&'
    )

    function __priority () {
        case $1 in
            '|')
                echo 1
                ;;
            '&')
                echo 2
                ;;
            *)
                return 255
                ;;
        esac
    }

    local p1 p2 ret
    if [[ -n $1 && -n $2 ]]; then
        p1=$(__priority "$1")
        p2=$(__priority "$2")
        if [[ -n $p1 && -n $p2 ]]; then
            ret="$((p1 - p2))"
        else
            ret=
        fi
    else
        ret="${OPERATORS[*]}"
    fi

    unset -f __priority
    echo "${ret:?}"
}
