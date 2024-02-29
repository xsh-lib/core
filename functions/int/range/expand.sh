# shellcheck disable=SC2148

#? Description:
#?   Expand a set of numbers and/or number ranges into a list of numbers.
#?
#? Usage:
#?   expand <NUMBER|RANGE> [...]
#?
#? Options:
#?   <NUMBER|RANGE>: a set of numbers and/or number ranges, the range's delimiter is dash `-`.
#?
#? Output:
#?   The expanded numbers separated with whitespace and sorted in ASC order, the duplicates are merged.
#?
#? Example:
#?   $ @expand 0-3 2 4 6
#?   0 1 2 3 4 6
#?
function expand () {
    declare item
    for item in "$@"; do
        # shellcheck disable=SC2046
        seq $(awk -F- '{print $1, $NF}' <<< "${item:?}")
    done | sort -n | uniq | xargs
}
