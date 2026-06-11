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
#?   $ arr=([3]="III" [4]="IV"); @first arr
#?   III
#?
function first () {
    declare __ifirst
    __ifirst=$(xsh /array/ifirst "${1:?}")
    if [[ -z ${__ifirst} ]]; then
        # empty array
        return 1
    fi
    eval "echo \"\${${1}[${__ifirst}]}\""
}
