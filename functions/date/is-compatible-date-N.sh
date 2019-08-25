#? Description:
#?   Test whether date command support Microsecond format: +%N.
#?
#? Usage:
#?   @is-compatible-datetime-N
#?
#? Example:
#?   @is-compatible-datetime-N; echo $?
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-datetime-N () {
    date +%N | grep [0-9] >/dev/null 2>&1
}
