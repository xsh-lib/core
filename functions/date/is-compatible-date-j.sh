#? Description:
#?   Test whether date command support option: -j.
#?
#? Usage:
#?   @is-compatible-date-j
#?
#? Example:
#?   $ @is-compatible-date-j; echo $?
#?   0
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-date-j () {
    xsh /util/is-compatible date -j
}
