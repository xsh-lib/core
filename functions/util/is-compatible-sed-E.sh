#? Description:
#?   Test whether sed has options '-E'.
#?
#? Usage:
#?   @is-compatible-sed-E
#?
#? Example:
#?   $ @is-compatible-sed-E; echo $?
#?   0
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-sed-E () {
    x-util-is-compatible sed -E '' /dev/null
}
