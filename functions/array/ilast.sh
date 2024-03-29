#? Usage:
#?   @ilast ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   The index of last element in the array.
#?
#? Example:
#?   $ arr=([3]="III" [4]="IV"); @ilast arr
#?   4
#?
function ilast () {
    # try to declare nothing, new variable may override input variable.
    # shellcheck disable=SC2046
    set -- $(xsh /array/index "$1")
    echo "${!#}"
}
