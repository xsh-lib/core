#? Description:
#?   Copy dotfiles from the repository to HOME (deploy repo changes).
#?
#?   Direction: repo -> HOME.
#?
#?   If a post-install action is defined in the map (e.g. "source"),
#?   a hint is printed after all files are copied. Post-install
#?   commands are NOT executed automatically because they typically
#?   need to run in the caller's shell context.
#?
#? Usage:
#?   @install <-a | NAME>
#?
#? Options:
#?   -a       Install all registered dotfiles.
#?   NAME     Install dotfiles matching NAME (substring match).
#?            At least one of -a or NAME is required.
#?
#? Example:
#?   $ @install bash_profile
#?     INSTALL bash/bash_profile  -> ~/.bash_profile
#?
#?     To apply changes, run:
#?       source ~/.bash_profile
#?
#?   $ @install -a
#?     INSTALL bash/bash_profile  -> ~/.bash_profile
#?     INSTALL aws/config         -> ~/.aws/config
#?     ...
#?
function install () {
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

    declare repo_file home_file post_cmd display target_dir
    declare -a source_hints=()

    while IFS=$'\t' read -r repo_file home_file post_cmd display; do
        [[ $post_cmd == "-" ]] && post_cmd=""
        if [[ ! -f $repo_file ]]; then
            printf "  SKIP %-28s (repo file missing)\n" "$display" >&2
            continue
        fi

        # ensure target directory exists
        target_dir=$(dirname "$home_file")
        if [[ ! -d $target_dir ]]; then
            mkdir -p "$target_dir"
        fi

        cp -a "$repo_file" "$home_file"
        printf "  INSTALL %-25s -> %s\n" "$display" "~${home_file#$HOME}"

        # collect post-install hints
        if [[ -n $post_cmd ]]; then
            if [[ $post_cmd == "source" ]]; then
                source_hints+=("source ~${home_file#$HOME}")
            else
                source_hints+=("$post_cmd")
            fi
        fi
    done <<< "$output"

    # print post-install hints
    if [[ ${#source_hints[@]} -gt 0 ]]; then
        printf "\n  To apply changes, run:\n"
        declare hint
        for hint in "${source_hints[@]}"; do
            printf "    %s\n" "$hint"
        done
    fi
}
