#? Usage:
#?   @confirm -m MESSAGE [-p POSITIIVE] [-n NEGATIVE] [-t TIMEOUT]
#?
#? Option:
#?   -m MESSAGE     Message prompted on screen.
#?
#?   [-p POSITIVE]  Positive token. Default is 'yes'.
#?
#?   [-n NEGATIVE]  Negative token. Default is 'no'.
#?
#?   [-t TIMEOUT]   Timeout in seconds, default no timeout.
#?
#? Output:
#?   None.
#?
#? Example:
#?   
#?   
#?
function confirm () {
    local OPTIND OPTARG opt
    local message verbose positive negative timeout
    local options REPLY

    positive=yes
    negative=no

    while getopts m:p:n:t: opt; do
        case $opt in
            m)
                message=${OPTARG}
                ;;
            p)
                positive=${OPTARG}
                ;;
            n)
                negative=${OPTARG}
                ;;
            t)
                timeout=${OPTARG}
                ;;
            *)
                return 255
                ;;
        esac
    done

    if [[ -z ${message} ]]; then
        printf "ERROR: message is null or not set.\n" >&2
        return 255
    fi

    if [[ -z ${positive} || -z ${negative} ]]; then
        printf "ERROR: positive or negative token is null or not set.\n" >&2
        return 255
    fi

    options=()
    xsh /array/append options "-p" "${message} [${positive}/${negative}]: "

    if [[ -n ${timeout} ]]; then
        xsh /array/append options "-t" "${timeout}"
    fi

    while read "${options[@]}" REPLY && [[ ${REPLY} != ${positive} && ${REPLY} != ${negative} ]]; do
        :
    done

    if [[ -z ${REPLY} ]]; then  # timeout
        REPLY=${negative}
        printf "%s\n" "${REPLY}"
        # Pause a short time to give chance to interrupt
        sleep 1
    fi

    if [[ ${REPLY} == ${negative} ]]; then
        return 1
    elif [[ ${REPLY} == ${positive} ]]; then
        return 0
    else
        return 255
    fi
}