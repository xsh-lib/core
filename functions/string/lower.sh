#? Usage:
#?   @lower STRING ...
#?
#? Output:
#?   Lowercase presentation of STRING.
#?
#? Example:
#?   @lower Foo
#?   FOO
#?
function lower () {
    echo "$@" | xsh /string/pipe/lower
}
