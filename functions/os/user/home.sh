#? Description:
#?   Get the user's home directory by username regardless of whether is running with `sudo`.
#?   The username is checked, it must exist, to avoid the arbitrary code execution of `eval`.
#?   The returned home directory's existence is not checked.
#?
#? Usage:
#?   @home [USERNAME]
#?
#? Options:
#?   [USERNAME]
#?
#?   The default USERNAME is current user.
#?
#? Example:
#?   $ @home foo
#?   /home/foo
#?
#?   $ @home bar
#?   /Users/bar
#?
function home () {
    if id "${1:-$(whoami)}" >/dev/null 2>&1; then
        eval echo "~$1"
    else
        return 255
    fi
}
