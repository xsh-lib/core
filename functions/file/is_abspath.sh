#? Usage:
#?   @is_abspath PATH
#?
#? Options:
#?   PATH   File path.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   @is_abspath /tmp; echo $?
#?   # 0
#?
function is_abspath () {
    [[ "${1:0:1}" == '/' ]]
}
