#? Usage:
#?   @inext ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   The index of next element in the array.
#?
#? Example:
#?   unset arr; arr[3]=III; arr[4]=IV
#?   @inext arr
#?   5
#?
function inext () {
    local index=$(xsh /array/ilast "$1")
    [[ -n $index ]] && echo $((index + 1)) || echo 0
}
