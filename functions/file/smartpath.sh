#? Description:
#?   Resolve absolute path for a file with following order.
#?
#?     1. If the `file` is an absolute path, then resolved with `file`.
#?     2. If the `dir` is given, and the `dir/file` exists, then resolved with
#?        the absolute path of `dir/file`.
#?     3. If the `file` exists, then resolved with the absolute path of `file`.
#?     4. If $BASH_SOURCE is not `-bash`, and the `$(dirname $BASH_SOURCE)/file` exists, then
#?        resolved with absolute path of `$(dirname $BASH_SOURCE)/file`.
#?
#?   Return error if none of above succeeded.
#?
#? Usage:
#?   @smartpath PATH
#?
#? Options:
#?   PATH   File or directory path.
#?
#? Output:
#?   Absolute path of input PATH.
#?
#? Example:
#?   $ cd /tmp; mkdir foo; touch foo/bar.zip
#?   $ @smartpath bar.zip foo
#?   /tmp/foo/bar.zip
#?
function smartpath () {
    declare file=${1:?}
    declare dir=$2

    declare source_file=-bash
    if [[ -n ${ZSH_VERSION-} ]]; then
        # zsh has no BASH_SOURCE; prompt escape %x expands to the file
        # containing the source code currently being executed
        eval 'source_file=${(%):-%x}'
    else
        source_file=${BASH_SOURCE[0]}
    fi

    if xsh /file/is-abspath "${file:?}"; then
        echo "$file"
    elif [[ -n $dir && -f $dir/$file ]]; then
        xsh /file/abspath "$dir/$file"
    elif [[ -f $file ]]; then
        xsh /file/abspath "$file"
    elif [[ ${source_file} != -bash && -f "$(dirname "${source_file}")/$file" ]]; then
        xsh /file/abspath "$(dirname "${source_file}")/$file"
    else
        xsh log error "not found: $file $dir"
        return 255
    fi
}
