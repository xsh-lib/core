#? Edition:
#?   Way of jot - macOS only.
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

    if [[ -z ${str} ]]; then
        return
    fi

    jot -b "${str}" -s "" "${times}"
}
