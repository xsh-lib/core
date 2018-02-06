#? Usage:
#?   @copy SRC_ARRAY NEW_ARRAY
#?
#? Options:
#?   SRC_ARRAY  Array name copying from.
#?   NEW_ARRAY  Array name copying to.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   src=([3]="III" [4]="IV"); @copy src new; declare -p new
#?   # declare -a new='([3]="III" [4]="IV")'
#?
function copy () {
    local __i

    if [[ $1 == $2 ]]; then
        return 255
    else
        unset "$2"
    fi

    for __i in $(xsh /array/index "$1"); do
	    xsh /string/copy "$1[${__i}]" "$2[${__i}]" || return $?
    done
}
