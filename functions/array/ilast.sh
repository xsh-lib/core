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
#?   unset arr; arr[3]=III; arr[4]=IV
#?   @ilast arr
#?   4
#?
function ilast () {
    local index=$(eval echo \${!$1[@]})
    echo ${index/ */}
}
