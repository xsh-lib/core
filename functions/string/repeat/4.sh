#? Edition:
#?   Way of head -c N /dev/zero and sed.
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
#?   1. losing `\`
#?      @repeat 'Foo\nBar' 3
#?
function repeat () {
    local str=$1 times=${2:-1}

    if [[ -z ${str} ]]; then
        return
    fi

    head -c "${times}" /dev/zero | sed "s|.|${str}|g"
}
