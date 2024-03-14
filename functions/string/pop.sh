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
    declare var
    declare val=${!1}

    var=$(declare \
              | grep -E -o "^[_]*$1[_]*" \
              | awk -F "$1" '$1 == $2' \
              | sort \
              | head -1)

    if [[ -z ${var} ]]; then
	    xsh log error "no further can be popped."
	    return 255
    fi

    if xsh /string/copy "${var}" "$1"; then
        unset "${var}"
        echo "${val}"
    else
        return $?
    fi
}
