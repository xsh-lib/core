#? Description:
#?   Test whether awk has option `--re-interval`.
#?
#? Usage:
#?   @is-compatible-awk-re-interval
#?
#? Example:
#?   $ @is-compatible-awk-re-interval; echo $?
#?   0
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-awk-re-interval () {
    test -z "$(awk --re-interval '' /dev/null 2>&1)"
}
