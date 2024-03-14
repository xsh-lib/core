#? Description:
#?   Set RETURN trap command.
#?   Fire the command on the RETURN signal of functions.
#?
#? Usage:
#?   xsh import /trap/return
#?   x-trap-return [-1] [-fF NAME] [-a] <COMMAND>
#?
#?   This util can't be called in the `xsh` leading syntax: `@return`, because
#?   `xsh` defines its own `RETURN trap`, that will break the trap chain.
#?
#? Options:
#?   [-1]         Clean trap after fired once.
#?   [-fF NAME]   Fire the command only with the fireable functions having the NAME.
#?                -f: Fire on each return of function with NAME.
#?                -F: Fire on the last return of function with NAME.
#?                    Usually necessary with loop calls or nested calls.
#?   [-a]         Append command to existing RETURN trap commands.
#?   <COMMAND>    Command to fire.
#?                For current returned function, following info is available inside
#?                the COMMAND:
#?                  * Return code:   available as `$1`.
#?                  * Function name: available as `${FUNCNAME[1]}'.
#?
#? Return:
#?   The return code of the trapped function is always honored.
#?
#? Output:
#?   The stdout of COMMAND is redirected to stderr, to avoid to mess the original output.
#?
#? Fire:
#?   By default, the command is being fired on each return of the functions
#?   which are in the upstream calling chain for calling this function.
#?
#?   The command won't be fired on the return of this fucntion.
#?
#?   If a RETURN trap is defined in any function of the calling chain,
#?   the RETURN trap definded here will stop before that function.
#?
#?   If any function of the calling chain is called in a subshell,
#?   the RETURN trap definded here will stop at that function.
#?
#? Clean:
#?   By default, the trap is cleaned on the last fireable function returns.
#?
#? Self Clean:
#?   This util trys its best to clean itself. The self clean needs to be done on
#?   the last time of firing the command. However for some case this is impossible.
#?   E.g.: A middle RETURN trap in the calling chain will terminate the trap chain
#?   earlier which can't be aware by this util.
#?   In such case, following resources remain uncleaned:
#?     * variable __XSH_TRAP_RETURN_CLEAN_FLAG
#?     * function __xsh_trap_return_bypass__ ()
#?     * function __xsh_trap_return_on_return__ ()
#?
function return () {

    #? Description:
    #?   Count the number of given function name in ${FUNCNAME[@]}
    #?
    #? Usage:
    #?   __xsh_count_in_funcstack__ <FUNCNAME>
    #?
    function __xsh_count_in_funcstack__ () {
        # shellcheck disable=SC2317
        printf '%s\n' "${FUNCNAME[@]}" \
            | grep -c "^${1}$"
    }

    declare OPTIND OPTARG opt
    declare fire_once=0 fire_on_last=0 fire_on_name append=0

    while getopts 1f:F:a opt; do
        case $opt in
            1)
                fire_once=1
                ;;
            f)
                fire_on_name=$OPTARG
                ;;
            F)
                fire_on_last=1
                fire_on_name=$OPTARG
                ;;
            a)
                append=1
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # generate function code

    declare funcode

    if [[ $append -eq 1 ]] && \
           declare -f __xsh_trap_return_on_return__ >/dev/null; then
        funcode=$(
            declare ln
            while IFS=$'' read -r ln; do
                if [[ $ln == '        };' ]]; then
                    # append new command
                    printf '%s\n' "$1"
                fi
                printf '%s\n' "$ln"
            done <<< "$(declare -f __xsh_trap_return_on_return__)"
               )
    else
        funcode='
        function __xsh_trap_return_bypass__ () {
            if [[ $__XSH_TRAP_RETURN_CLEAN_FLAG -eq 1 ]]; then
                # clean env: unset flag variable
                unset __XSH_TRAP_RETURN_CLEAN_FLAG;

                # clean env: unset self
                unset -f $FUNCNAME
            fi
            return $1
        }

        function __xsh_trap_return_on_return__ () {
            # skip the RETURN signal of registering function
            if [[ ${FUNCNAME[1]} == x-trap-return ]]; then
                return $1
            fi

            # global flag for cleaning RETURN trap
            __XSH_TRAP_RETURN_CLEAN_FLAG=0

            declare fire_on_name="'$fire_on_name'"
            declare fire_on_last="'$fire_on_last'"
            declare fire_once="'$fire_once'"

            # firing logic
            if [[ -z $fire_on_name \
                      || ( -n $fire_on_name \
                               && (( $fire_on_last -eq 0 && ${FUNCNAME[1]} == $fire_on_name ) \
                                        || ( $fire_on_last -eq 1 \
                                                 && ${FUNCNAME[1]} == $fire_on_name \
                                                 && $(__xsh_count_in_funcstack__ "$fire_on_name") == 1 )) )
                ]]; then

                # clean RETURN trap logic
                if  [[ $fire_once -eq 1 \
                           || ${#FUNCNAME[@]} -eq 2 \
                           || ( -n $fire_on_name && ${FUNCNAME[1]} == $fire_on_name \
                                    && $(__xsh_count_in_funcstack__ "$fire_on_name") == 1 ) \
                     ]]; then

                    # clean env: unset self
                    unset -f $FUNCNAME

                    # set flag for cleaning RETURN trap
                    __XSH_TRAP_RETURN_CLEAN_FLAG=1
                fi

                { # command begins
                '$1'
                } # command ends

            fi

            # return the former return code
            return $1
        }'
    fi

    if [[ -n $1 ]]; then
        # source the generated function
        source /dev/stdin <<< "$funcode"

        if [[ $? -ne 0 ]]; then
            xsh log error "failed source function: $funcode"
            return 255
        fi

        # set trap RETURN
        trap 'declare ret=$?; __xsh_trap_return_on_return__ $ret 1>&2; [[ $__XSH_TRAP_RETURN_CLEAN_FLAG -eq 1 ]] && trap - RETURN || :; __xsh_trap_return_bypass__ $ret' RETURN
    else
        xsh log error "parameter COMMAND null or not set."
        return 255
    fi
}
