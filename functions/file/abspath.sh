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
    if [[ ! -e $1 ]]; then
        printf "ERROR: PATH does not exist or permission denied.\n" >&2
        return 255
    fi

    if xsh /file/is_abspath "$1"; then
        echo "$1"
    else
        echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
    fi
}
