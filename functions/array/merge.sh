#? Description:
#?   Merge the elements of array by value, the later index of element would
#?   be used.
#?
#? Usage:
#?   @merge ARRAY [SEPARATOR]
#?
#? Options:
#?   ARRAY        Array name to merge.
#?   [SEPARATOR]  Separator in the value, if specified, only the part before
#?                the separator will be evaluated during the merge.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ arr=([3]="x=III" [4]="y=IV" [5]="y=V"); @merge arr =; declare -p arr
#?   declare -a arr='([3]="x=III" [5]="y=V")'
#?
#? Zsh:
#?   Zsh arrays can't be sparse: the surviving elements are re-indexed
#?   contiguously from 0, rather than keeping their original indices.
#?
function merge () {
    declare __i __j
    declare __val_i __val_j

    if [[ -z $1 ]]; then
        printf "ERROR: Array name is null or not set.\n" >&2
        return 255
    fi

    if [[ -n ${ZSH_VERSION-} ]]; then
        # zsh arrays can't be sparse: `unset 'arr[i]'` just empties the
        # element rather than removing it. Rebuild the array without the
        # merged-away elements instead; the surviving elements are
        # re-indexed contiguously.
        declare __len __survive
        declare -a __result
        eval "__len=\${#${1}[@]}"
        for (( __i=0; __i<__len; __i++ )); do
            eval "__val_i=\${${1}[${__i}]}"
            __survive=1
            for (( __j=__i+1; __j<__len; __j++ )); do
                eval "__val_j=\${${1}[${__j}]}"
                if [[ -z $2 ]]; then
                    if [[ ${__val_i} == "${__val_j}" ]]; then
                        __survive=0
                        break
                    fi
                else
                    if [[ ${__val_i%%"${2}"*} == "${__val_j%%"${2}"*}" ]]; then
                        __survive=0
                        break
                    fi
                fi
            done
            if [[ ${__survive} -eq 1 ]]; then
                __result+=( "${__val_i}" )
            fi
        done
        eval "${1}=( \"\${__result[@]}\" )"
        return
    fi

    for __i in $(xsh /array/index "$1"); do
        for __j in $(xsh /array/index "$1"); do
            if [[ $__j -le $__i ]]; then
                continue
            fi

            eval "__val_i=\${${1}[${__i}]}"
            eval "__val_j=\${${1}[${__j}]}"

            if [[ -z $2 ]]; then
                if [[ ${__val_i} == "${__val_j}" ]]; then
                    unset "${1}[${__i}]"
                    break
                fi
            else
                if [[ ${__val_i%%"${2}"*} == "${__val_j%%"${2}"*}" ]]; then
                    unset "${1}[${__i}]"
                    break
                fi
            fi
        done
    done
}
