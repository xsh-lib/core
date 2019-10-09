#? Usage:
#?   @last ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   The last element in the array.
#?
#? Example:
#?   $ arr=([3]="III" [4]="IV"); @last arr
#?   IV
#?
function last () {
    # try to declare nothing, new variable may override input variable.
    set -- "$1[$(xsh /array/ilast "$1")]"
    echo "${!1}"
}
