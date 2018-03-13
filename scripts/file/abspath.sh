#? Usage:
#?   @abspath PATH
#?
#? Options:
#?   PATH  File or directory path.
#?
#? Output:
#?   Absolute path of input PATH.
#?
#? Example:
#?   cd && @abspath ../../etc/passwd
#?   # /etc/passwd
#?
function abspath () {
    if [[ ${1:0:1} == '/' ]]; then
        echo "$1";
    else
        echo $(cd "$(dirname "$1")" && pwd)/$(basename "$1");
    fi
}

@abspath "$@"

exit
