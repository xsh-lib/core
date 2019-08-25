#? Description:
#?   Test whether date command support the option for adjusting date: -d.
#?
#? Usage:
#?   @is-compatible-date-d
#?
#? Example:
#?   @is-compatible-date-d; echo $?
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-date-d () {
    xsh /util/is-compatible date -d '1 second'
}
