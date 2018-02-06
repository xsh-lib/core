#? Usage:
#?   @index ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   The index of all elements in the array.
#?
#? Example:
#?   arr=([3]="III" [4]="IV"); @index arr
#?   # 3 4
#?
function index () {
    local -a __index=\(\${!$1[@]}\)  # magic indirect expansion
    printf "%s" "${__index[*]}"
}
