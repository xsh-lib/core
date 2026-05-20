#? Description:
#?   Resolve dotfile entries from the repository map file (.dotfilemap).
#?
#?   Each resolved entry is printed as a tab-separated line:
#?     <repo-file> <TAB> <home-file> <TAB> <post-install> <TAB> <display-name>
#?
#?   - repo-file:     Absolute path to the file in the repository.
#?   - home-file:     Absolute path to the file under HOME.
#?   - post-install:  Post-install hint ("-" if none).
#?   - display-name:  Repo-relative path (for display purposes).
#?
#? Usage:
#?   @resolve [NAME]
#?
#? Options:
#?   [NAME]   Optional filter. Matches against the repo-relative path,
#?            its basename, or the home path as a substring.
#?            If omitted, all entries are returned.
#?
#? Environment:
#?   XSH_DOTFILE_REPO   Path to the dotfile repository root.
#?                       Falls back to WORKSPACE_MACOS_DOTFILE if unset.
#?
#? Return:
#?   0 on success (at least one entry matched).
#?   255 if the repo or map file is not found, or no entry matched.
#?
#? Example:
#?   $ @resolve bash_profile
#?   /path/to/repo/bash/bash_profile	/Users/me/.bash_profile	source	bash/bash_profile
#?
#?   $ @resolve | head -1
#?   /path/to/repo/bash/bash_profile	/Users/me/.bash_profile	source	bash/bash_profile
#?
function resolve () {
    declare repo_dir name="${1:-}"

    repo_dir=${XSH_DOTFILE_REPO:-${WORKSPACE_MACOS_DOTFILE:-}}
    if [[ -z $repo_dir ]]; then
        printf "ERROR: XSH_DOTFILE_REPO (or WORKSPACE_MACOS_DOTFILE) is not set.\n" >&2
        return 255
    fi
    if [[ ! -d $repo_dir ]]; then
        printf "ERROR: dotfile repo not found: %s\n" "$repo_dir" >&2
        return 255
    fi

    declare map_file="$repo_dir/.dotfilemap"
    if [[ ! -f $map_file ]]; then
        printf "ERROR: map file not found: %s\n" "$map_file" >&2
        return 255
    fi

    declare line repo_path home_path post_cmd bn
    declare matched=0

    while IFS= read -r line || [[ -n $line ]]; do
        # skip comments and blank lines
        [[ -z $line || $line == \#* ]] && continue

        IFS=: read -r repo_path home_path post_cmd <<< "$line"

        # trim leading/trailing whitespace
        repo_path=${repo_path#"${repo_path%%[![:space:]]*}"}
        repo_path=${repo_path%"${repo_path##*[![:space:]]}"}
        home_path=${home_path#"${home_path%%[![:space:]]*}"}
        home_path=${home_path%"${home_path##*[![:space:]]}"}
        post_cmd=${post_cmd#"${post_cmd%%[![:space:]]*}"}
        post_cmd=${post_cmd%"${post_cmd##*[![:space:]]}"}

        # expand ~ in home_path
        home_path=${home_path/#\~/$HOME}

        # filter by name if given
        if [[ -n $name ]]; then
            bn=${repo_path##*/}
            if [[ $repo_path != *"$name"* && $bn != *"$name"* && $home_path != *"$name"* ]]; then
                continue
            fi
        fi

        printf '%s\t%s\t%s\t%s\n' \
            "$repo_dir/$repo_path" "$home_path" "${post_cmd:--}" "$repo_path"
        matched=1
    done < "$map_file"

    if [[ $matched -eq 0 ]]; then
        if [[ -n $name ]]; then
            printf "ERROR: no dotfile matching '%s'.\n" "$name" >&2
        else
            printf "ERROR: map file is empty or has no valid entries.\n" >&2
        fi
        return 255
    fi
}
