##? Usage:
#?   @copy SRC_VAR NEW_VAR
#?
#? Options:
#?   SRC_VAR  Variable name copying from.
#?   NEW_VAR  Variable name copying to.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   src=1
#?   @copy src new
#?   echo $new
#?   foo
#?
function copy () {
    [[ "$1" == "$2" ]] && return 9
    unset $2  # in case $2 is Array
    eval $2=\${!1}
}
