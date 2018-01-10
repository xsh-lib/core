#? Usage:
#?   @upper < /dev/stdin
#?
#? Output:
#?   Uppercase presentation of standard input.
#?
#? Example:
#?   echo Foo | @upper
#?   FOO
#?
function upper () {
    tr [:lower:] [:upper:] < /dev/stdin
}
