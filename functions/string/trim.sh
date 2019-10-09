#? Usage:
#?   @trim STRING ...
#?
#? Output:
#?   STRING removed leading and tailing blankspaces.
#?
#? Example:
#?   $ @trim '  Foo  '
#?   Foo
#?
function trim () {
    echo "$@" | xsh /string/pipe/trim
}
