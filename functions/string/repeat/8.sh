#? Edition:
#?   Way of recursion with x/math/lim.
#?
#? Usage:
#?   @repeat STRING [N]
#?
#? Options:
#?   STRING  String to repeat. `\n` safe.
#?   [N]     Repeat N times, default is 1, means no repeat.
#?
#? Output:
#?   Concatenation of N STRINGs.
#?
#? Example:
#?   @repeat Foo 3
#?   # FooFooFoo
#?
function repeat () {
    declare str=$1 times=${2:-1}
    declare result lstr lresult limit remain_times i

    if [[ -z ${str} ]]; then
        return
    fi

    lstr=${#str}
    lresult=$((lstr * times))
    limit=$(xsh /math/lim "${lresult}" "${lstr}" 2) || return

    i=0
    result=${str}
    while [[ ${i} -lt ${limit} ]]; do
        result=${result}${result} || return
        ((i++))
    done

    remain_times=$(((lresult - lstr * (2 ** limit)) / lstr))

    if [[ ${remain_times} -gt 0 ]]; then
        result=${result}$(xsh /string/repeat/8 "${str}" "${remain_times}")
    fi

    echo "${result}"
}
