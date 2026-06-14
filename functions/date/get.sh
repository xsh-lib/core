#? Description:
#?   Agent function to get parts from the given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @get <LIST> [-*] [...] [TIMESTAMP]
#?
#? Options:
#?   <LIST>        Options list allowed to call, delimited by blankspace.
#?                 The options prefixed with `%` are the defaults.
#?   [-*] [...]    Options to call.
#?                 If multiple options used, the outputs are delimited with blankspace.
#?                 The options must be in the LIST.
#?   [TIMESTAMP]   Timestamp.
#?
function get () {

    # the real implementation for the agent call
    function __get__ () {
        declare OPTIND OPTARG opt
        declare -a fmts

        while getopts "${OPTION:?}" opt; do
            # plain string membership: a dynamic extglob/alternation pattern
            # would not be matched as a pattern by zsh
            if [[ ${CONDITION:?} == *"|${opt}|"* ]]; then
                fmts+=( "%$opt" )
            else
                return 255
            fi
        done
        shift $((OPTIND - 1))

        # set default
        if [[ -z ${fmts[*]} ]]; then
            fmts=( "${DEFAULT_OPTIONS[@]:?}" )
        fi

        if [[ -z $1 ]]; then
            xsh /date/timestamp "+${fmts[*]}"
        else
            xsh /date/convert "$1" "+${fmts[*]}"
        fi
    }

    declare list=${1:?}

    declare OPTION DEFAULT_OPTIONS CONDITION

    # remove blankspace and `%`
    OPTION=${list//[ %]/}

    # shellcheck disable=SC2206
    DEFAULT_OPTIONS=( ${list} )
    # remove the non-default options
    DEFAULT_OPTIONS=( "${DEFAULT_OPTIONS[@]#[a-zA-Z]}" )

    # generate the allowed-options condition `|x|y|`
    CONDITION=${list//%/}
    CONDITION="|${CONDITION// /|}|"

    # call the real implementation
    __get__ "${@:2}"; declare ret=$?

    # clean env
    unset -f __get__

    return $ret
}
