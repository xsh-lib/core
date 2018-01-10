#? Usage:
#?   @space [N]
#?
#? Options:
#?   [N]  Generate N blankspaces, default is 1.
#?
#? Output:
#?   N blankspaces.
#?
#? Example:
#?   @space 6
#?   '     '
#?
function space () {
    xsh /string/repeat ' ' "${1:-1}"
}
