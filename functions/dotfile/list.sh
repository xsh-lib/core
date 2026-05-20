#? Description:
#?   List dotfiles registered in the repository map file (.dotfilemap).
#?
#? Usage:
#?   @list [NAME]
#?
#? Options:
#?   [NAME]   Optional filter (substring match against repo path,
#?            basename, or home path).
#?
#? Output:
#?   A formatted table showing each dotfile's repo-relative path,
#?   its corresponding home path, and post-install hint (if any).
#?
#? Example:
#?   $ @list
#?     bash/bash_profile                -> ~/.bash_profile              [source]
#?     aws/config                       -> ~/.aws/config
#?     git/gitconfig                    -> ~/.gitconfig
#?
#?   $ @list bash
#?     bash/bash_profile                -> ~/.bash_profile              [source]
#?     bash/env-davionlabs              -> ~/.env-davionlabs            [source]
#?
function list () {
    declare output
    output=$(xsh /dotfile/resolve "$@") || return $?

    declare repo_file home_file post_cmd display home_display hint

    while IFS=$'\t' read -r repo_file home_file post_cmd display; do
        [[ $post_cmd == "-" ]] && post_cmd=""
        home_display="~${home_file#$HOME}"
        if [[ -n $post_cmd ]]; then
            hint="  [$post_cmd]"
        else
            hint=""
        fi
        printf "  %-32s -> %-30s%s\n" "$display" "$home_display" "$hint"
    done <<< "$output"
}
