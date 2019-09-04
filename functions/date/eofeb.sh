#? Description:
#?   Get the end day of Feb of a given year.
#?
#? Usage:
#?   @eofeb <TIMESTAMP>
#?
#? Example:
#?   @eofeb 2012
#?   29
#?
#?   @eofeb 2011
#?   28
#?
function eofeb () {
    if xsh /date/is-leapyear "${1:?}"; then
        echo 29
    else
        echo 28
    fi
}
