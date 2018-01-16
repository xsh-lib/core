#? Version:
#?   Way of awk printf in while.
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

    awk -v str=${str} -v times=${times} 'BEGIN {while (i++ < times) printf str}'
}
