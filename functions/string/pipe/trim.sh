#? Usage:
#?   @trim < /dev/stdin
#?
#? Output:
#?   String from standard input, removed leading and tailing blankspaces.
#?
#? Example:
#?   echo '  Foo  ' | @trim
#?   'Foo'
#?
function trim () {
    sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' < /dev/stdin
}
