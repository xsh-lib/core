#? Usage:
#?   @sign NUMBER
#?
#? Output:
#?   1, -1, 0, -0, or ''.
#?
function sign () {
    if test "$1" == '0'; then
        echo 0
    elif test "$1" == '-0'; then
        echo -0
    elif test "$1" -gt 0; then
        echo 1
    elif test "$1" -lt 0; then
        echo -1
    else
        printf "ERROR: unknown error" >&2
    fi
}
