#? Usage:
#?   @concat ARRAY1 ARRAY2
#?
#? Options:
#?   ARRAY1  Array name joining to.
#?   ARRAY2  Array name joining from.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   arr1=([3]="III" [4]="IV"); arr2=([0]="V" [1]="VI")
#?   @concat arr1 arr2; declare -p arr1
#?   # declare -a arr1='([3]="III" [4]="IV" [5]="V" [6]="VI")'
#?
function concat () {
    local __i __j

    __i=$(xsh /array/inext "$1")
    for __j in $(xsh /array/index "$2"); do
	    xsh /string/copy "$2[${__j}]" "$1[$((__i+__j))]" || return $?
    done
}
