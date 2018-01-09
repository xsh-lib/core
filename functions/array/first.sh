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
#?   unset arr; arr[3]=III; arr[4]=IV
#?   @first arr
#?   III
#?
function first () {
    eval echo \"\${$1[$(xsh /array/ifirst "$1")]}\"
}
