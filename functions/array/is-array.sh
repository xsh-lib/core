#? Usage:
#?   @is-array VAR
#?
#? Options:
#?   VAR  Variable name.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ @is-array BASH_ARGV; echo $?
#?   0
#?
function is-array () {
    [[ "$(declare -p "$1" 2>/dev/null || :)" =~ "declare -a" ]]
}
