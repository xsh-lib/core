##? Usage:
#?   @pop VAR
#?
#? Options:
#?   VAR  Variable name popping from.
#?
#? Output:
#?   The value popped.
#?
#? Example:
#?   var=0; @push var 10; @push var 20
#?   $ @pop var; @pop var; echo $var
#?   20
#?   10
#?   0
#?
function pop () {
    local var
    local val=${!1}

    var=$(declare \
              | egrep -o "^[_]*$1[_]*" \
              | awk -F "$1" '$1 == $2' \
              | sort \
              | head -1)

    if [[ -z ${var} ]]; then
	    echo "$FUNCNAME: no further can be popped." >&2
	    return 255
    fi

    if xsh /string/copy "${var}" "$1"; then
        unset "${var}"
        echo "${val}"
    else
        return $?
    fi
}
