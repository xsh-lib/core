#? Version:
#?   Way of printf -v
#?
#? Usage:
#?   @append VAR VALUE
#?
#? Options:
#?   VAR    Variable name appending to.
#?   VALUE  Value to append.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   var=PI; @append var '=3.14'; echo "$var"
#?   # PI=3.14
#?
function append () {
    printf -v "$1" "%s" "${!1}$2"
}
