#? Usage:
#?   @lower STRING ...
#?
#? Output:
#?   Lowercase presentation of STRING.
#?
#? Example:
#?   $ @lower Foo
#?   foo
#?
function lower () {
    echo "$@" | xsh /string/pipe/lower
}
