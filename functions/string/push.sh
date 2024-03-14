##? Usage:
#?   @push VAR VALUE
#?
#? Options:
#?   VAR    Variable name pushing to.
#?   VALUE  Value to push.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ var=0; @push var 10; @push var 20; echo $var
#?   20
#?
function push () {
    xsh /string/copy \
        "$1" \
        "_$(declare | grep -E -o "^[_]*$1[_]*" \
                    | awk -F "$1" '$1 == $2' \
                    | sort \
                    | head -1)_" \
        && read -r "$1" <<< "$2"
}
