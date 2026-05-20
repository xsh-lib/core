#? Description:
#?   Copy dotfiles from HOME into the repository (save local changes).
#?
#?   Direction: HOME -> repo.
#?
#? Usage:
#?   @load <-a | NAME>
#?
#? Options:
#?   -a       Load all registered dotfiles.
#?   NAME     Load dotfiles matching NAME (substring match).
#?            At least one of -a or NAME is required.
#?
#? Example:
#?   $ @load bashrc
#?     LOAD bash/bashrc          <- ~/.bashrc
#?
#?   $ @load -a
#?     LOAD bash/bashrc          <- ~/.bashrc
#?     LOAD git/gitconfig        <- ~/.gitconfig
#?     ...
#?
function load () {
    declare OPTIND OPTARG opt
    declare all=0

    while getopts a opt; do
        case $opt in
            a)
                all=1
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ $all -eq 0 && $# -eq 0 ]]; then
        printf "ERROR: specify NAME or use -a for all.\n" >&2
        return 255
    fi

    declare filter=""
    [[ $all -eq 0 ]] && filter=$1

    declare output
    output=$(xsh /dotfile/resolve "$filter") || return $?

    declare repo_file home_file post_cmd display

    while IFS=$'\t' read -r repo_file home_file post_cmd display; do
        if [[ ! -f $home_file ]]; then
            printf "  SKIP %-28s (home file missing: %s)\n" \
                "$display" "~${home_file#$HOME}" >&2
            continue
        fi
        cp -a "$home_file" "$repo_file"
        printf "  LOAD %-28s <- %s\n" "$display" "~${home_file#$HOME}"
    done <<< "$output"
}
