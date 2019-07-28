#? Description:
#?   Test whether a command is compitable with current environment.
#?
#? Usage:
#?   @is_compitable CMD [OPTIONS]
#?
#? Example:
#?   @is_compatible sed -r '' /dev/zero; echo $?
#?   # 1
#?
#? Return:
#?   0:     Compitable
#?   != 0:  Not compitable 
#?
#? Output:
#?   Nothing.
#?
function is_compitable () {
    "$@" >/dev/null 2>&1
}
