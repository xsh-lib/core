#? Description:
#?  A pseudo keyword like the Shell builtin 'local'.
#?
#?  Create a global variable called NAME, and give it VALUE.
#?  Unlike 'local'. this one can be used both inside and
#?  outside a function.
#?
#? Usage:
#?   @global NAME[=VALUE]
#?
#? Options:
#?   NAME   Variable name.
#?   VALUE  Value set for NAME.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ vname=foo; @global $vname=bar; echo $foo
#?   bar
#?
function global () {
    read -r "${1%%=*}" <<< "${1#*=}"
}
