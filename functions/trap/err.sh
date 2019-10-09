#? Description:
#?   Print better message on ERR signal.
#?
#? Usage:
#?   xsh /trap/err [-E] [-e] [-r]
#?
#? Options:
#?   [-E]         If set, the ERR trap is inherited by shell functions.
#?   [-e]         If set, exit on error.
#?   [-r]         If set, return on error.
#?                Make sure use this option inside function.
#?
#? Output:
#?   The stdout of COMMAND is redirected to stderr, to avoid to mess the original output.
#?
function err () {
    local OPTIND OPTARG opt
    local on_error

    while getopts Eer opt; do
        case $opt in
            E)
                set -E
                ;;
            e)
                on_error=exit
                ;;
            r)
                on_error=return
                ;;
            *)
                return 255
                ;;
        esac
    done

    # generate function code

    local funcode

    funcode='
        function __xsh_trap_err_on_err__ () {
            local ret=$1
            local command=$2
            local lineno=$3
            local func=($4)  # do not double quote the parameter
            local script=$5
            local source=("${@:6}")

            local max_index
            max_index=$(printf "%s\n" ${!func[@]} ${!source[@]} | sort -rn | head -1)

            printf "Error code: %s\n" "$ret"
            printf "Traceback (most recent call first)\n"

            if [[ -n $max_index ]]; then
                local index
                for index in $(seq 0 "$max_index"); do
                    if [[ $script == -bash || $index -gt 0 ]]; then
                        lineno=?
                    fi
                    printf "  File \"%s\", line %s, in %s\n" "${source[$index]:-<stdin>}" "$lineno" "${func[$index]}"
                    if [[ $index -eq 0 ]]; then
                        printf "    %s\n" "$command"
                    fi
                done
            fi
            printf "\n"

            return $ret
        }'

    # source the generated function
    source /dev/stdin <<< "$funcode"

    if [[ $? -ne 0 ]]; then
        xsh log error "failed source function: $funcode"
        return 255
    fi

    # set trap ERR
    trap '__xsh_trap_err_on_err__ $? \
         "${BASH_COMMAND}" "${LINENO}" "${FUNCNAME[*]}" "$0" "${BASH_SOURCE[@]}" 1>&2; \
         '$on_error ERR
}
