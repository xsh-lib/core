#? Description:
#?   Test whether date command support the option for adjusting datetime: -v.
#?
#? Usage:
#?   @is-compatible-date-v
#?
#? Example:
#?   @is-compatible-date-v; echo $?
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-date-v () {
    xsh /util/is-compatible date -v +1S
}
