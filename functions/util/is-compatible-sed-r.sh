#? Description:
#?   Test whether sed has options '-r'.
#?
#? Usage:
#?   @is-compatible-sed-r
#?
#? Example:
#?   @is-compatible-sed-r; echo $?
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-sed-r () {
    x-util-is-compatible sed -r '' /dev/null
}
