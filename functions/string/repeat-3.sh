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

    if [[ -z ${str} ]]; then
        return
    fi

    local pmln=$(( $(xmath.log_pmln "${#str}" 2 "${times}") + 2 )) || return 1

    local i=0 i_str=${str}
    while [[ ${i} -lt ${pmln} ]]; do
        i_str=${i_str}${i_str} || return 1
	    let i++
    done

    echo ${i_str} | head -c $(( ${#str} * times ))
}
