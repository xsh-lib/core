#? Usage:
#?   @is-relpath PATH
#?
#? Options:
#?   PATH   File path.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ @is-relpath /tmp; echo $?
#?   1
#?
function is-relpath () {
    [[ "${1:0:1}" != '/' ]]
}
