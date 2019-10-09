#? Usage:
#?   @is_relpath PATH
#?
#? Options:
#?   PATH   File path.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ @is_relpath /tmp; echo $?
#?   1
#?
function is_relpath () {
    [[ "${1:0:1}" != '/' ]]
}
