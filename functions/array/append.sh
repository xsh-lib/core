#? Usage:
#?   @append ARRAY VALUE ...
#?
#? Options:
#?   ARRAY  Array name appending to.
#?   VALUE  Value to append.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   arr=([3]="III" [4]="IV"); @append arr V VI; declare -p arr
#?   # declare -a arr='([3]="III" [4]="IV" [5]="V" [6]="VI")'
#?
function append () {
    local __i

    if [[ $# -lt 2 ]]; then
        return 255
    fi

    for __i in $(seq 2 $#); do
        # clear IFS to avoid triming whitespace
        IFS='' read -r "$1[$(xsh /array/inext "$1")]" <<< "${!__i}" || return $?
    done
}
