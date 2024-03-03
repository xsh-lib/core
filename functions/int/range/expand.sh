# shellcheck disable=SC2148

#? Description:
#?   Expand a set of numbers and/or number ranges into a list of numbers.
#?
#? Usage:
#?   expand [-r] <NUMBER|RANGE> [...]
#?
#? Options:
#?   [-r]
#?
#?   Sort the output in DESC order.
#?   Default is in ASC order.
#?
#?   <NUMBER|RANGE>: a set of numbers and/or number ranges, the range's delimiter is dash `-`.
#?
#? Output:
#?   The expanded numbers separated with whitespace, the duplicates are merged.
#?
#? Example:
#?   $ @expand 0-3 2 4 6
#?   0 1 2 3 4 6
#?
function expand () {
    declare OPTIND OPTARG opt
    declare -a sort_opts=( -n )

    while getopts r opt; do
        case $opt in
            r)
                sort_opts=( "${sort_opts[@]}" -r )
                ;;
            *)
                return 255
                ;;
        esac
    done
    
    declare item
    for item in "$@"; do
        # shellcheck disable=SC2046
        seq $(awk -F- '{print $1, $NF}' <<< "${item:?}")
    done | sort "${sort_opts[@]}" | uniq | xargs
}
