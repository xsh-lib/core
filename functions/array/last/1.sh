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
    declare __ilast
    __ilast=$(xsh /array/ilast "${1:?}")
    if [[ -z ${__ilast} ]]; then
        # empty array
        return 1
    fi
    eval "echo \"\${${1}[${__ilast}]}\""
}
