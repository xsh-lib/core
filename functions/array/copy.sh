# foo:desc
# Copy array 1 (named by $1) to array 2 (named by $2).
# An source array with incontinuouse indeces,
# such as a=([0]=0 [3]=3 [9]=9), 
# after copied, the indeces will be the same.

# foo:usage:
# x=(1 2 3)
# $foo x y
# echo ${y[@]}
# 1 2 3

function copy () {
    [[ $1 == $2 ]] && return 9
    unset $2
    local i
    for i in $(eval echo \${!$1[@]})
    do
	    xsh /string/copy "$1[$i]" "$2[$i]" || return $?
    done
    return $?
}
