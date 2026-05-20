#? Description:
#?   Show differences between HOME and repository versions of dotfiles.
#?
#?   By default uses the terminal diff tool ($DIFF_TOOL, or `diff`).
#?   With -g, opens a GUI diff tool ($GUI_DIFF_TOOL, or `bcomp`).
#?
#? Usage:
#?   @diff [-g] <-a | NAME>
#?
#? Options:
#?   -g       Use GUI diff tool ($GUI_DIFF_TOOL).
#?   -a       Diff all registered dotfiles.
#?   NAME     Diff dotfiles matching NAME (substring match).
#?            At least one of -a or NAME is required.
#?
#? Environment:
#?   DIFF_TOOL       Terminal diff command (default: diff).
#?   GUI_DIFF_TOOL   GUI diff command (default: bcomp).
#?
#? Example:
#?   $ @diff bash_profile
#?   === bash/bash_profile ===
#?   < ...
#?   > ...
#?
#?   $ @diff -g bash_profile
#?   (opens Beyond Compare)
#?
#?   $ @diff -a
#?   === bash/bash_profile ===
#?   ...
#?   === git/gitconfig ===
#?   ...
#?
function diff () {
    declare OPTIND OPTARG opt
    declare all=0 gui=0

    while getopts ag opt; do
        case $opt in
            a)
                all=1
                ;;
            g)
                gui=1
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

    declare diff_tool
    if [[ $gui -eq 1 ]]; then
        diff_tool=${GUI_DIFF_TOOL:-bcomp}
    else
        diff_tool=${DIFF_TOOL:-diff}
    fi

    declare repo_file home_file post_cmd display
    declare count=0

    while IFS=$'\t' read -r repo_file home_file post_cmd display; do
        if [[ ! -f $repo_file ]]; then
            printf "  SKIP %s (repo file missing)\n" "$display" >&2
            continue
        fi
        if [[ ! -f $home_file ]]; then
            printf "  SKIP %s (home file missing: %s)\n" \
                "$display" "~${home_file#$HOME}" >&2
            continue
        fi

        if [[ $gui -eq 1 ]]; then
            command "$diff_tool" "$repo_file" "$home_file"
        else
            if [[ $count -gt 0 ]]; then
                printf "\n"
            fi
            printf "=== %s ===\n" "$display"
            # diff exits 1 when files differ; not an error here
            command "$diff_tool" "$repo_file" "$home_file" || true
        fi
        count=$((count + 1))
    done <<< "$output"
}
