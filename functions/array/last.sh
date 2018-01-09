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
#?   unset arr; arr[3]=III; arr[4]=IV
#?   @last arr
#?   IV
#?
function last () {
    eval echo \"\${$1[$(xsh /array/ilast "$1")]}\"
}
