#? Usage:
#?   @padding STRING PADDING LENGTH
#?
#? Options:
#?   STRING
#?   PADDING
#?   LENGTH
#?
#? Output:
#?
#? Example:
#?   @padding '1010' '0' 8
#?   00001010
#?   @padding '1010' '10' 8
#?   10101010
#?   @padding '1010' '10' 9
#?   ERROR
#?
padding () {
    local str=$1 padding=$2 len=$3
    local gap

    if [[ -z ${str} || -z ${padding} || -z ${len} ]]; then
        return 9
    fi

    gap=$((len - ${#str}))
    if [[ ${gap} -lt 0 ]] ; then
        printf "ERROR: target LENGTH can not be less than STRING's length.\n" >&2
        return 9
    fi

    if [[ $((gap % ${#padding})) -ne 0 ]]; then
        printf "ERROR: STRING can not be padded with '%s' to be LENGTH %s.\n" "${padding}" "${len}" >&2
        return 9
    fi

    echo "$(xsh /string/repeat "${padding}" "$((gap / ${#padding}))")${str}"
}
