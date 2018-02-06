#? Usage:
#?   @ifirst ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   The index of first element in the array.
#?
#? Example:
#?   arr=([3]="III" [4]="IV"); @ifirst arr
#?   # 3
#?
function ifirst () {
    # try to declare nothing, new variable may override input variable.
    set -- $(xsh /array/index "$1")
    printf "%s" "${1%% *}"
}
