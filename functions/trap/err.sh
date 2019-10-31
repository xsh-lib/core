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
#? Highlight:
#?   About `trap <command> ERR`, from `man bash`.
#?
#?   If a sigspec is ERR, the command arg is executed whenever a simple command
#?   has a non-zero exit status, subject to the following conditions.
#?
#?   The ERR trap is not executed ...
#?     * if the failed command is part of the command list immediately following
#?       a while or until keyword,
#?     * part of the test in an if statement,
#?     * part of a && or || list,
#?     * or if the command's return value is being inverted via !.
#?   These are the same conditions obeyed by the errexit option.
#?
#? Clean:
#?   The ERR trap is NOT cleaned by any means, your should handle this in your code.
#?
#? Self Clean:
#?   This util have to left a resource remain uncleaned:
#?     * function __xsh_trap_err_on_err__ ()
#?
function err () {
    declare OPTIND OPTARG opt
    declare on_error

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

    declare funcode

    funcode='
        function __xsh_trap_err_on_err__ () {
            declare ret=$1
            declare command=$2
            declare lineno=$3
            declare func=($4)  # do not double quote the parameter
            declare script=$5
            declare source=("${@:6}")

            declare max_index
            max_index=$(printf "%s\n" ${!func[@]} ${!source[@]} | sort -rn | head -1)

            printf "Error code: %s\n" "$ret"
            printf "Traceback (most recent call first)\n"

            if [[ -n $max_index ]]; then
                declare index
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
