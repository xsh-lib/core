#? Usage:
#?   @abspath PATH
#?
#? Options:
#?   PATH   File or directory path.
#?
#? Output:
#?   Absolute path of input PATH.
#?
#? Example:
#?   $ cd && @abspath ../../etc/passwd
#?   /etc/passwd
#?
function abspath () {
    declare dir file

    if [[ -z $1 ]]; then
        printf "ERROR: parameter PATH null or not set.\n" >&2
        return 255
    fi

    if [[ ! -e $1 ]]; then
        printf "ERROR: PATH does not exist or permission denied.\n" >&2
        return 255
    fi

    if xsh /file/is-abspath "$1"; then
        echo "$1"
    elif [[ -d $1 ]]; then
        cd "$1" && pwd
    else
        dir=$(cd "$(dirname "$1")" && pwd)
        file=$(basename "$1")

        if [[ -z ${dir} || -z ${file} ]]; then
            printf "ERROR: failed to get dir or file part.\n" >&2
            return 255
        else
            echo "${dir}/${file}"
        fi
    fi
}
