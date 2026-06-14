#? Description:
#?   Let you be able to use `getopts` in this way: `./script -x foo bar -y baz`
#?   It will set an array OPTARGS=(foo bar) for the option `-x`.
#?   This works only within the `getopts` context.
#?   This util must be import first before to use. Because the function `xsh`
#?   will break the OPTIND and OPTARG variables.
#?
#? Usage:
#?   x-util-getopts-extra "$@"
#?
#? Example:
#?   xsh imports /util/getopts/extra
#?   while getopts x:y: opt; do
#?     case $opt in
#?       x)
#?         x-util-getopts-extra "$@"; x=( "${OPTARGS[@]}" );;
#?       y)
#?         y=$OPTARG;;
#?     esac
#?   done
#?
#? Bash:
#?   For backward compatibility, under bash the array is additionally set
#?   into OPTARG: x=( "${OPTARG[@]}" ).
#?
#? Zsh:
#?   Under zsh OPTARG is a special scalar that can never hold an array
#?   value: only OPTARGS is set.
#?
#?   IMPORTANT: under zsh the calling function must run under ksh emulation
#?   (`emulate -L ksh`) - functions imported by xsh do automatically. In a
#?   native zsh function the write to OPTIND restarts the caller's getopts
#?   parsing from scratch, looping forever.
#?
function extra () {
    if [[ -z ${OPTIND} ]]; then
        xsh log error "not in the context of getopts."
        return 255
    fi

    declare -a __extra__
    declare __next__
    # if the next argument is not an option, then append it to array OPTARG
    while [[ ${OPTIND} -le $# ]]; do
        # `${!OPTIND}` is bash-only; `${*:N:1}` works in both shells
        __next__=${*:$((OPTIND)):1}
        if [[ ${__next__:0:1} == '-' ]]; then
            break
        fi
        __extra__+=( "${__next__}" )
        ((OPTIND++))
    done

    # the portable result: OPTARGS holds all the values of the option
    # shellcheck disable=SC2034
    OPTARGS=( "${OPTARG[@]}" "${__extra__[@]}" )

    if [[ -z ${ZSH_VERSION-} ]]; then
        # bash only: keep the original behavior, the array OPTARG.
        # zsh: OPTARG is a special scalar that can never hold an array
        # value (even via `unset`, the special is re-exposed); use OPTARGS.
        OPTARG=( "${OPTARG[@]}" "${__extra__[@]}" )
    fi
}
