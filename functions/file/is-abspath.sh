#? Usage:
#?   @is-abspath PATH
#?
#? Options:
#?   PATH   File path.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ @is-abspath /tmp; echo $?
#?   0
#?
function is-abspath () {
    [[ "${1:0:1}" == '/' ]]
}
