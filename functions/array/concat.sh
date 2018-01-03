# foo:desc:
# Concat array 2 (named by $2) to array 1 (named by $1).
# Both array's index will be kept.

# foo:usage:
# x=(1 2 3)
# y=(4 5 6)
# $foo x y
# echo ${x[@]}
# 1 2 3 4 5 6

function x-array-concat () {
    local i j
    i=$(xsh array/ilast $1)
    i=$((i + 1))

    for j in $(eval echo \${!$2[@]})
    do
	    xsh string/copy "$2[$j]" "$1[$(( i + j ))]" || return $?
    done
    return $?
}
