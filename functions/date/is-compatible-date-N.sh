#? Description:
#?   Test whether date command support Nanosecond format: +%N.
#?
#? Usage:
#?   @is-compatible-date-N
#?
#? Example:
#?   @is-compatible-date-N; echo $?
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-date-N () {
    date +%N | grep [0-9] >/dev/null 2>&1
}
