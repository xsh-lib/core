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
#?                    NOTE: bash doesn't expose the argument of an explicit
#?                    `return N` to the RETURN trap: under bash `$1` is the
#?                    status of the last command executed before the return
#?                    (they are the same when the function returns implicitly).
#?                    Under zsh `$1` is the actual return code.
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
#? Zsh:
#?   Zsh has no RETURN trap. Under zsh this util emulates it with a cascade of
#?   function-scoped EXIT traps (NO_POSIX_TRAPS): an EXIT trap set inside a
#?   function fires on that function's return, and the trap command re-arms
#?   the trap in the caller's scope, walking up the calling chain like the
#?   bash RETURN trap does.
#?   Differences from the bash behavior:
#?     * The trap fires only on the returns of the upstream calling chain
#?       captured at registering time, not on the returns of functions called
#?       afterwards (with `-fF NAME` the net effect is the same).
#?     * The cascade always stops at the top level, the trap never outlives
#?       the calling chain.
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

    if [[ -n ${ZSH_VERSION-} ]]; then
        if [[ -z $1 ]]; then
            xsh log error "parameter COMMAND null or not set."
            return 255
        fi

        if [[ $append -eq 1 && -n ${__XSH_TRAP_RETURN_COMMAND-} ]]; then
            # the armed trap reads the command from the global at firing time
            typeset -g __XSH_TRAP_RETURN_COMMAND=${__XSH_TRAP_RETURN_COMMAND}$'\n'$1
            return 0
        fi

        typeset -g __XSH_TRAP_RETURN_COMMAND=$1
        typeset -g __XSH_TRAP_RETURN_FIRE_ONCE=$fire_once
        typeset -g __XSH_TRAP_RETURN_FIRE_ON_LAST=$fire_on_last
        typeset -g __XSH_TRAP_RETURN_FIRE_ON_NAME=$fire_on_name

        # the name of the function whose return fires the trap the next time;
        # starts with this function itself, whose return is always skipped
        set -- "${funcstack[@]}"
        typeset -g __XSH_TRAP_RETURN_FUNCNAME=$1
        typeset -g __XSH_TRAP_RETURN_REGISTER_FUNCNAME=$1

        #? Description:
        #?   Evaluate the firing and cleaning logic on each return of the
        #?   functions in the calling chain.
        #?   Called from the cascading EXIT trap: at that point the returned
        #?   function is already popped off `funcstack`, and the current
        #?   scope is the function the trap will be re-armed in.
        #?
        #? Usage:
        #?   __xsh_trap_return_on_exit__ <RETURN_CODE>
        #?
        # shellcheck disable=SC2329  # invoked indirectly by the trap command
        function __xsh_trap_return_on_exit__ () {
            # pin bash-compatible (0-indexed) arrays and word splitting for
            # the eval of the trapped COMMAND
            emulate -L ksh

            declare __rc=$1

            # the name of the function that just returned
            declare __returning=${__XSH_TRAP_RETURN_FUNCNAME-}

            # the remaining calling chain: funcstack minus this function
            set -- "${funcstack[@]}"
            shift
            declare __chain_len=$#

            # remember the name for the next firing
            typeset -g __XSH_TRAP_RETURN_FUNCNAME=${1-}

            declare __fire_once=${__XSH_TRAP_RETURN_FIRE_ONCE:-0}
            declare __fire_on_last=${__XSH_TRAP_RETURN_FIRE_ON_LAST:-0}
            declare __fire_on_name=${__XSH_TRAP_RETURN_FIRE_ON_NAME-}

            typeset -g __XSH_TRAP_RETURN_CLEAN_FLAG=0

            # skip the return of the registering function
            if [[ $__returning != "${__XSH_TRAP_RETURN_REGISTER_FUNCNAME-}" ]]; then
                # count the occurrences of the fireable name in the chain
                declare __count=0 __name
                if [[ -n $__fire_on_name ]]; then
                    for __name in "$@"; do
                        if [[ $__name == "$__fire_on_name" ]]; then
                            __count=$((__count + 1))
                        fi
                    done
                fi

                # firing logic: the returned function is already off the
                # chain, so `last return of NAME` means: the returned
                # function is NAME and NAME is not in the remaining chain
                if [[ -z $__fire_on_name \
                          || ( $__returning == "$__fire_on_name" \
                                   && ( $__fire_on_last -eq 0 || $__count -eq 0 ) ) ]]; then

                    # clean logic
                    if [[ $__fire_once -eq 1 \
                              || $__chain_len -eq 0 \
                              || ( -n $__fire_on_name \
                                       && $__returning == "$__fire_on_name" \
                                       && $__count -eq 0 ) ]]; then
                        typeset -g __XSH_TRAP_RETURN_CLEAN_FLAG=1
                    fi

                    # make the documented context available to COMMAND:
                    # $1 as the return code, ${FUNCNAME[1]} as the function name
                    # shellcheck disable=SC2034
                    declare -a FUNCNAME=( "${0}" "$__returning" "$@" )
                    set -- "$__rc"

                    { # command begins
                        eval "${__XSH_TRAP_RETURN_COMMAND}"
                    } # command ends
                fi
            fi

            # the cascade can't be re-armed at the top level
            if [[ $__chain_len -eq 0 ]]; then
                typeset -g __XSH_TRAP_RETURN_CLEAN_FLAG=1
            fi

            # do not need to explicitly return the former return code, trap would handle this
        }

        # the cascading trap command: evaluate the firing logic, then either
        # re-arm the trap in the current (caller's) scope or clean up.
        # NOTE: the `trap` builtin must be executed directly in the trap
        # command, not inside a function, for the new trap to be scoped to
        # the function the cascade has unwound to.
        # shellcheck disable=SC2016  # the expansions belong to firing time
        typeset -g __XSH_TRAP_RETURN_TRAP='__xsh_trap_return_on_exit__ "$?" 1>&2
            if [[ ${__XSH_TRAP_RETURN_CLEAN_FLAG-} -eq 1 ]]; then
                unset __XSH_TRAP_RETURN_CLEAN_FLAG __XSH_TRAP_RETURN_COMMAND \
                      __XSH_TRAP_RETURN_FIRE_ONCE __XSH_TRAP_RETURN_FIRE_ON_LAST \
                      __XSH_TRAP_RETURN_FIRE_ON_NAME __XSH_TRAP_RETURN_FUNCNAME \
                      __XSH_TRAP_RETURN_REGISTER_FUNCNAME __XSH_TRAP_RETURN_TRAP
                unset -f __xsh_trap_return_on_exit__
            else
                setopt no_posix_traps
                trap "${__XSH_TRAP_RETURN_TRAP}" EXIT
            fi'

        # arm the trap on this function: with NO_POSIX_TRAPS it fires when
        # this function returns, and the cascade takes over from there.
        # `emulate -L ksh` (applied on import) makes the setopt local.
        setopt no_posix_traps
        # shellcheck disable=SC2064  # the value is the static trap script
        trap "${__XSH_TRAP_RETURN_TRAP}" EXIT

        return 0
    fi

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
        # shellcheck disable=SC2016
        funcode='
        function __xsh_trap_return_bypass__ () {
            if [[ $__XSH_TRAP_RETURN_CLEAN_FLAG -eq 1 ]]; then
                # clean env: unset flag variable
                unset __XSH_TRAP_RETURN_CLEAN_FLAG;

                # clean env: unset self
                unset -f $FUNCNAME
            fi
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

            # do not need to explicitly return the former return code, trap would handle this
        }'
    fi

    if [[ -n $1 ]]; then
        # source the generated function
        # shellcheck source=/dev/null
        if ! source /dev/stdin <<< "$funcode"; then
            xsh log error "failed source function: $funcode"
            return 255
        fi

        # set trap RETURN
        # `$?` passes the return code of the trapped function to the
        # generated function, where it is available to COMMAND as `$1`
        # shellcheck disable=SC2154
        trap '__xsh_trap_return_on_return__ "$?" 1>&2; [[ $__XSH_TRAP_RETURN_CLEAN_FLAG -eq 1 ]] && trap - RETURN || :; __xsh_trap_return_bypass__' RETURN
    else
        xsh log error "parameter COMMAND null or not set."
        return 255
    fi
}
