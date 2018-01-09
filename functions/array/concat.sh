#? Usage:
#?   @concat ARRAY1 ARRAY2
#?
#? Output:
#?   Nothing
#?
#? Example:
#?   arr1=(1 2 3)
#?   arr2=(4 5 6)
#?   @concat arr1 arr2
#?   echo ${arr1[@]}
#?   1 2 3 4 5 6
#?
function concat () {
    local i j
    i=$(xsh /array/ilast $1)
    i=$((i + 1))

    for j in $(eval echo \${!$2[@]})
    do
	    xsh /string/copy "$2[$j]" "$1[$(( i + j ))]" || return $?
    done
}
