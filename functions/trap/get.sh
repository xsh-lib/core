#? Description:
#?   Get former trap command for signal.
#?
#?   If former trap was set with `trap '' SIGNAL`, output ''.
#?   If former trap was unset or cleaned with `trap - SIGNAL`, output '-'.
#?
#? Usage:
#?   @get [-e] <SIGNAL>
#?
#? Option:
#?   [-e]      Output the entire trap expression rather than the command.
#?
function get () {
    local OPTIND OPTARG opt
    local expr=0

    while getopts e opt; do
        case $opt in
            e)
                expr=1
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    local str
    str=$(trap -p "${1:?}")

    if [[ -z $str && $expr -eq 0 ]]; then
        str=-
    elif [[ -z $str && $expr -eq 1 ]]; then
        str="trap - ${1:?}"
    elif [[ -n $str && $expr -eq 0 ]]; then
        str=${str#trap -- \'}
        str=${str%\' *}
    fi

    printf '%s\n' "$str"
}
