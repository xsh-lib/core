##? Usage:
#?   @pop VAR
#?
#? Options:
#?   VAR  Variable name poping from.
#?
#? Output:
#?   The value poped.
#?
#? Example:
#?   var=0
#?   @push var 10
#?   @push var 20
#?   echo $var  # 20
#?   @pop var  # 20
#?   @pop var  # 10
#?   echo $var  # 0
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
	    echo "$FUNCNAME: no further can be poped." >&2
	    return 9
    fi

    if xsh /string/copy "${var}" "$1"; then
        unset "${var}"
        echo "${val}"
    else
        return $?
    fi
}
