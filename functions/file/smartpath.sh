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

    if xsh /file/is-abspath "${file:?}"; then
        echo "$file"
    elif [[ -n $dir && -f $dir/$file ]]; then
        xsh /file/abspath "$dir/$file"
    elif [[ -f $file ]]; then
        xsh /file/abspath "$file"
    elif [[ $BASH_SOURCE != -bash && -f "$(dirname "$BASH_SOURCE")/$file" ]]; then
        xsh /file/abspath "$(dirname "$BASH_SOURCE")/$file"
    else
        xsh log error "not found: $file $dir"
        return 255
    fi
}
