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
#?   $ arr=([3]="III" [4]="IV"); @ilast arr
#?   4
#?
function ilast () {
    # try to declare nothing, new variable may override input variable.
    # shellcheck disable=SC2046
    set -- $(xsh /array/index "$1")
    # NOTE: `${!#}` is bash-only (zsh silently expands it as `$#`), and
    # expands to `$0` when there is no argument; `${*: -1}` works in both
    # shells and expands to nothing when there is no argument
    echo "${*: -1}"
}
