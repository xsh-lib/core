#? Description:
#?   Test whether a command is compatible with current environment.
#?
#? Usage:
#?   @is-compatible CMD [OPTIONS]
#?
#? Example:
#?   $ @is-compatible sed -r '' /dev/zero; echo $?
#?   0
#?
#? Return:
#?   0:     Compitable
#?   != 0:  Not compatible
#?
#? Output:
#?   Nothing.
#?
function is-compatible () {
    "$@" >/dev/null 2>&1
}
