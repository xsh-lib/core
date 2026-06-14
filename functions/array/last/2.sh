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
    declare __len
    eval "__len=\${#${1:?}[@]}"
    if [[ ${__len} -eq 0 ]]; then
        # empty array
        return 1
    fi
    # NOTE: a negative offset `:(-1)` is unsupported by bash 3.2 and zsh;
    # use the explicit offset instead
    eval "echo \"\${${1}[@]:$((__len - 1))}\""
}
