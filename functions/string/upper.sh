#? Usage:
#?   @upper STRING ...
#?
#? Output:
#?   Uppercase presentation of STRING.
#?
#? Example:
#?   $ @upper Foo
#?   FOO
#?
function upper () {
    echo "$@" | xsh /string/pipe/upper
}
