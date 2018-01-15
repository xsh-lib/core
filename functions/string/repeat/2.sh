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
    local result len lim remain_times i

    if [[ -z ${str} ]]; then
        return
    fi

    len=$((${#str} * times))
    lim=$(xsh /math/lim "${len}" "${#str}" 2) || return

    i=0
    result=${str}
    while [[ ${i} -lt ${lim} ]]; do
        result=${result}${result} || return
        let i++
    done

    remain_times=$(((len - ${#str} * (2 ** lim)) / ${#str}))

    if [[ ${remain_times} -gt 0 ]]; then
        result=${result}$(xsh /string/repeat "${str}" "${remain_times}")
    else
        :
    fi

    echo "${result}"
}
