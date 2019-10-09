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
#?   $ src=1; @copy src new; echo $new
#?   foo
#?   $ src=(x y z); @copy src[0] new[0]; echo ${new[0]}
#?   x
#?
function copy () {
    if [[ "$1" == "$2" ]]; then
        return 255
    else
        unset "$2"  # in case $2 is Array
    fi
    read -r "$2" <<< "${!1}"
}
