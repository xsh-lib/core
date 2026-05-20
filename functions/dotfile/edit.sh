#? Description:
#?   Open the repository copy of a dotfile in an editor.
#?
#?   By default uses $GUI_EDITOR (matching the existing alias convention).
#?   With -t, uses $EDITOR for terminal editing.
#?
#? Usage:
#?   @edit [-t] NAME
#?
#? Options:
#?   [-t]     Use terminal editor ($EDITOR) instead of GUI editor.
#?   NAME     Dotfile to edit (substring match).
#?
#? Environment:
#?   GUI_EDITOR   GUI editor command (default: $EDITOR or vim).
#?   EDITOR       Terminal editor command (default: vim).
#?
#? Example:
#?   $ @edit bash_profile        # opens in $GUI_EDITOR (e.g. VS Code)
#?   $ @edit -t gitconfig        # opens in $EDITOR (e.g. vim)
#?
function edit () {
    declare OPTIND OPTARG opt
    declare terminal=0

    while getopts t opt; do
        case $opt in
            t)
                terminal=1
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ $# -eq 0 ]]; then
        printf "ERROR: NAME is required.\n" >&2
        return 255
    fi

    declare editor
    if [[ $terminal -eq 1 ]]; then
        editor=${EDITOR:-vim}
    else
        editor=${GUI_EDITOR:-${EDITOR:-vim}}
    fi

    declare output
    output=$(xsh /dotfile/resolve "$1") || return $?

    declare repo_file home_file post_cmd display

    while IFS=$'\t' read -r repo_file home_file post_cmd display; do
        command "$editor" "$repo_file"
    done <<< "$output"
}
