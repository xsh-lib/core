#? Usage:
#?   @first ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   The first element in the array.
#?
#? Example:
#?   arr=([3]="III" [4]="IV"); @first arr
#?   # III
#?
function first () {
    # try to declare nothing, new variable may override input variable.
    set -- "$1[$(xsh /array/ifirst "$1")]"
    echo "${!1}"
}
