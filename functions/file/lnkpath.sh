#? Description:
#?   Follow all symbolic links to final target and output the absolute path
#?   of target.
#?
#? Usage:
#?   @lnkpath LINK [DIR]
#?
#? Options:
#?   LINK   Absolute or relative path to the symbol link.
#?   [DIR]  Absolute or relative path to the directory of symbol link.
#?
#? Output:
#?   Absolute path of the final target that the LINK refers to.
#?
#? Example:
#?   mkdir -p /tmp/symblink/foo \
#?       && touch /tmp/symblink/foo/f1
#?       && ln -s foo/f1 /tmp/symblink/f2 \
#?       && ln -s f2 /tmp/symblink/f3
#?
#?   @lnkpath /tmp/symblink/f3
#?   # /tmp/symblink/foo/f1
#?
#?   cd /tmp
#?   @lnkpath f3 symblink
#?   # /tmp/symblink/foo/f1
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
