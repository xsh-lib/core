#? Usage:
#?   @lower < /dev/stdin
#?
#? Output:
#?   Lowercase presentation of standard input.
#?
#? Example:
#?   echo Foo | @lower
#?   FOO
#?
function lower () {
    tr [:upper:] [:lower:] < /dev/stdin
}
