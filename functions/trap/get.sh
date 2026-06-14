#? Description:
#?   Get former trap command for signal.
#?
#?   If former trap was set with `trap '' SIGNAL`, output ''.
#?   If former trap was unset or cleaned with `trap - SIGNAL`, output '-'.
#?
#? Usage:
#?   @get [-e] <SIGNAL>
#?
#? Options:
#?   [-e]      Output the entire trap expression rather than the command.
#?
#? Zsh:
#?   Zsh resets traps in subshells, including command substitution: calling
#?   this util as `$(xsh /trap/get SIGNAL)` always reports no trap. Call it
#?   in the current shell, e.g. redirect the output to a file, instead.
#?   Multiline trap commands are output as a single line, quoted with $'...'.
#?
function get () {
    declare OPTIND OPTARG opt
    declare expr=0

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

    declare str
    if [[ -n ${ZSH_VERSION-} ]]; then
        # zsh resets traps in subshells: `$(trap ...)` always sees none, and
        # zsh's trap builtin has no `-p`. List the traps into a temp file in
        # the current shell and filter by the signal name instead.
        # NOTE: zsh lists each trap as a single line, quoting multiline
        # commands with $'...'.
        declare tmpfile=/tmp/xsh-trap-get-$$-$RANDOM
        trap > "$tmpfile"
        str=$(grep " ${1:?}\$" "$tmpfile" || :)
        /bin/rm -f "$tmpfile"
    else
        str=$(trap -p "${1:?}")
    fi

    if [[ -z $str && $expr -eq 0 ]]; then
        str=-
    elif [[ -z $str && $expr -eq 1 ]]; then
        str="trap - ${1:?}"
    elif [[ -n $str && $expr -eq 0 ]]; then
        str=${str#trap -- }
        str=${str% *}
        case $str in
            \$\'*)
                str=${str#\$\'}
                str=${str%\'}
                ;;
            \'*)
                str=${str#\'}
                str=${str%\'}
                ;;
        esac
    fi

    printf '%s\n' "$str"
}
