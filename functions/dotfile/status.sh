#? Description:
#?   Show the sync status of registered dotfiles by comparing the HOME
#?   copy against the repository copy.
#?
#? Usage:
#?   @status [NAME]
#?
#? Options:
#?   [NAME]   Optional filter (substring match).
#?
#? Output:
#?   A status line per dotfile:
#?     [=]  Files are identical (in sync).
#?     [M]  Files differ (modified).
#?     [!]  One side is missing (home or repo file not found).
#?
#? Example:
#?   $ @status
#?     [=] bash/bashrc
#?     [M] git/gitconfig
#?     [!] ssh/config                    (home file missing)
#?     [=] vim/vimrc
#?
function status () {
    declare output
    output=$(xsh /dotfile/resolve "$@") || return $?

    declare repo_file home_file post_cmd display

    while IFS=$'\t' read -r repo_file home_file post_cmd display; do
        if [[ ! -f $repo_file ]]; then
            printf "  [!] %-32s (repo file missing)\n" "$display"
        elif [[ ! -f $home_file ]]; then
            printf "  [!] %-32s (home file missing)\n" "$display"
        elif command diff -q "$repo_file" "$home_file" >/dev/null 2>&1; then
            printf "  [=] %s\n" "$display"
        else
            printf "  [M] %s\n" "$display"
        fi
    done <<< "$output"
}
