#? Usage:
#?   @merge ARRAY VALUE [SEPARATOR]
#?
#? Options:
#?   ARRAY        Array name to merge.
#?   [SEPARATOR]  Separator in the value.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   arr=([3]="x=III" [4]="y=IV" [5]="y=V"); @merge arr =; declare -p arr
#?   # declare -a arr='([3]="x=III" [5]="y=V")'
#?
function merge () {
    local __i __j
    local __arr_i __arr_j

    if [[ -z $1 ]]; then
        printf "ERROR: Array name is null or not set.\n" >&2
        return 255
    fi

    for __i in $(xsh /array/index "$1"); do
        __arr_i="$1[__i]"

        for __j in $(xsh /array/index "$1"); do
            if [[ $__j -le $__i ]]; then
                continue
            fi

            __arr_j="$1[__j]"

            if [[ -z $2 ]]; then
                if [[ ${!__arr_i} == ${!__arr_j} ]]; then
                    unset ${__arr_i}
                    break
                fi
            else
                if [[ ${!__arr_i%%${2}*} == ${!__arr_j%%${2}*} ]]; then
                    unset ${__arr_i}
                    break
                fi
            fi
        done
    done
}