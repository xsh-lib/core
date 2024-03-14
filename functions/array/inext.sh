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
#?   $ arr=([3]="III" [4]="IV"); @inext arr
#?   5
#?
function inext () {
    # shellcheck disable=SC2046
    set -- $(xsh /array/ilast "$1")
    case "$1" in
        '')
            echo 0
            ;;
        *)
            echo $(($1+1))
            ;;
    esac
}
