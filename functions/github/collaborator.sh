#? Description:
#?   This script provides a command line interface to operate on the collaborators
#?   of Github repositories.
#?
#? Dependency:
#?   1. collaborator
#?      https://github.com/maxogden/collaborator
#?      You need to manully install `collaborator` before to use this utility.
#?
#?   2. w3m
#?      You need to manully install `w3m` before to use this utility.
#?
#? Usage:
#?   @collaborator
#?     [-a USER] [...]
#?     [-d USER] [...]
#?
#? Options:
#?   [-a USER] [...]
#?
#?   Username of Github, neither the Email nor the nickname.
#?   Add collaborators to current repository.
#?
#?   [-d USER] [...]
#?
#?   Username of Github, neither the Email nor the nickname.
#?   Remove collaborators from current repository.
#?
#?   If called without any options, then show existing collaborators of current
#?   repository.
#?
#? Example:
#?   @collaborator
#?
#? @xsh /trap/err -e
#? @subshell
#?
function collaborator () {

    #? Usage:
    #?   highlight_line <PATTERN> <FILE>
    function highlight_line () {
        awk -v pattern="$1" -v HB='\033[1m' -v HE='\033[0m' \
            '{if(match($0, pattern) > 0) print HB $0 HE; else print}' \
            "${2:-/dev/stdin}"
    }

    local OPTIND OPTARG opt

    declare -a a_users d_users
    while getopts a:d: opt; do
        case $opt in
            a)
                a_users+=("$OPTARG")
                ;;
            d)
                d_users+=("$OPTARG")
                ;;
            h|*)
                usage
                ;;
        esac
    done

    declare repo_path repo
    repo_path=$(git rev-parse --show-toplevel)
    repo=$(basename "$repo_path")

    declare user
    declare -a users

    # add collaborators
    if [[ ${#a_users[@]} -gt 0 ]]; then
        printf "adding %s collaborator(s) to repo %s:\n" \
               "${#a_users[@]}" "$repo"
        for user in "${a_users[@]}"; do
            printf "* %s ..." "$user"
            collaborator --add $user >/dev/null 2>&1
            printf " [done]\n"
        done
        printf '\n'
        users+=("${#a_users[@]}")
    fi

    # remove collaborators
    if [[ ${#d_users[@]} -gt 0 ]]; then
        printf "removing %s collaborator(s) from repo %s:\n" \
               "${#d_users[@]}" "$repo"
        for user in "${d_users[@]}"; do
            printf "* %s ..." "$user"
            collaborator --del $user >/dev/null 2>&1
            printf " [done]\n"
        done
        printf '\n'
        users+=("${#d_users[@]}")
    fi

    # list collaborators
    if [[ ${#users[@]} -gt 0 ]]; then
        collaborator | w3m -dump -T text/html \
            | highlight_line "$(IFS=\|; echo "${users[*]}")"
    else
        collaborator | w3m -dump -T text/html
    fi
}
