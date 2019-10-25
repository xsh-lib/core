#? Edition:
#?   Way of BSD seq - macOS only.
#?
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
#?   @repeat Foo 3
#?   # FooFooFoo
#?
#? Bug:
#?   1. raise error with `%` in string.
#?      @repeat '%s' 3
#?
function repeat () {
    local str=$1 times=${2:-1}

    if [[ -z ${str} ]]; then
        return
    fi

    seq -f "${str}" -s "" "${times}"
}
