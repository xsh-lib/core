#? Usage:
#?   @repeat STRING [N]
#?
#? Options:
#?   STRING  String to repeat.
#?   [N]     Repeat N times, default is 1, means no repeat.
#?
#? Output:
#?   Concatenation of N STRINGs.
#?
#? Example:
#?   @repeat Foo
#?   Foo
#?   @repeat Foo 3
#?   FooFooFoo
#?
function repeat () {
    local str=$1 times=${2:-1}
    local n i i_str

    if [[ -z ${str} ]]; then
        return
    fi

    n=$(xsh /math/lim "${times}" "${#str}" 2) || return

    i=0
    i_str=${str}
    while [[ ${i} -lt ${n} ]]; do
        i_str=${i_str}${i_str} || return
        let i++
    done

    echo "${i_str}"
}
