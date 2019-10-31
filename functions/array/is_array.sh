#? Usage:
#?   @is_array VAR
#?
#? Options:
#?   VAR  Variable name.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ @is_array BASH_ARGV; echo $?
#?   0
#?
function is_array () {
    [[ "$(declare -p "$1" 2>/dev/null || :)" =~ "declare -a" ]]
}
