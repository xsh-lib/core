#? Usage:
#?   @index ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   The index of all elements in the array.
#?
#? Example:
#?   $ arr=([3]="III" [4]="IV"); @index arr
#?   3 4
#?
function index () {
    if [[ -n ${ZSH_VERSION-} ]]; then
        # zsh has no `${!arr[@]}`, and zsh arrays are never sparse: the
        # indices are always contiguous, 0 .. len-1 under the ksh emulation
        declare __len __i __index=
        eval "__len=\${#${1:?}[@]}"
        for (( __i=0; __i<__len; __i++ )); do
            __index=${__index}${__index:+ }${__i}
        done
        echo "${__index}"
    else
        declare -a __index
        eval "__index=( \"\${!${1:?}[@]}\" )"
        echo "${__index[@]}"
    fi
}
