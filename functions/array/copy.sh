#? Usage:
#?   @copy SRC_ARRAY NEW_ARRAY
#?
#? Options:
#?   SRC_ARRAY  Array name copying from.
#?   NEW_ARRAY  Array name copying to.
#?
#? Example:
#?   src=(1 2 3)
#?   @copy src new
#?   echo ${new[@]}
#?   1 2 3
#?
function copy () {
    local i

    if [[ $1 == $2 ]]; then
        return 9
    else
        unset $2
    fi

    for i in $(eval echo \${!$1[@]}); do
	    xsh /string/copy "$1[$i]" "$2[$i]" || return $?
    done
}
