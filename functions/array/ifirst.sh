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
#?   unset arr; arr[3]=III; arr[4]=IV
#?   @ifirst arr
#?   3
#?
function ifirst () {
    local index=$(eval echo \${!$1[@]})
    echo ${index/ */}
}
