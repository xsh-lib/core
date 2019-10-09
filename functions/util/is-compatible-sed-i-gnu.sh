#? Description:
#?   Test whether sed option `-i` has the GNU syntax: -i''.
#?
#? Usage:
#?   @is-compatible-sed-i-gnu
#?
#? Example:
#?   $ @is-compatible-sed-i-gnu; echo $?
#?   0
#?
#? Return:
#?   0:     Yes
#?   != 0:  No
#?
#? Output:
#?   Nothing.
#?
function is-compatible-sed-i-gnu () {
    local tmpfile=/tmp/xsh-sed-compatible-$RANDOM
    local ret=0

    touch "$tmpfile" \
        && {
        x-util-is-compatible sed -i '' "$tmpfile"
        ret=$?
        /bin/rm -f "$tmpfile"
    }
    return $ret
}
