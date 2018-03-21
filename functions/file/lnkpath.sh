#? Usage:
#?   @lnkpath LINK [DIR]
#?
#? Options:
#?   LINK   Symbol link path.
#?   [DIR]  In case of: `PWD` + DIR + LINK
#?
#? Output:
#?   Absolute path of the file that the symbol link referred.
#?
#? Example:
#?   mkdir -p /tmp/symblink/foo/bar/f4 \
#?       && ln -s f4 /tmp/symblink/foo/bar/f3 \
#?       && ln -s bar/f3 /tmp/symblink/foo/f2 \
#?       && ln -s foo/f2 /tmp/symblink/f1
#?   @lnkpath /tmp/symblink/f1
#?   # /tmp/symblink/foo/bar/f4
#?
function lnkpath () {
    local link=$1
    local dir=$2
    local file

    if [[ ${link:0:1} != '/' ]]; then
        if [[ -z ${dir} ]]; then
            link=$(pwd)/${link}
        else
            link=${dir}/${link}
        fi
    fi

    file=$(readlink "${link}")

    if [[ -n ${file} ]]; then
        xsh /file/lnkpath "${file}" "$(dirname "${link}")"
    else
        xsh /file/abspath "${link}"
    fi
}