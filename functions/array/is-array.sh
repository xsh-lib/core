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
    # bash declares arrays as `declare -a`, zsh as `typeset -a` or
    # `typeset -g -a`; keep the regex in a variable for bash 3.2 (a quoted
    # regex is matched literally there)
    declare __re='^(declare|typeset) (-g )?-a'
    [[ "$(declare -p "$1" 2>/dev/null || :)" =~ $__re ]]
}
