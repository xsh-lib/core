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
    declare __popping_from_variable_name
    declare __popping_value=${!1}

    __popping_from_variable_name=$(declare \
              | grep -E -o "^[_]*$1[_]*" \
              | awk -F "$1" '$1 == $2' \
              | sort \
              | head -1)

    if [[ -z ${__popping_from_variable_name} ]]; then
	    xsh log error "no further can be popped."
	    return 255
    fi

    if xsh /string/copy "${__popping_from_variable_name}" "$1"; then
        unset "${__popping_from_variable_name}"
        echo "${__popping_value}"
    else
        return $?
    fi
}
