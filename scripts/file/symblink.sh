#? Usage:
#?   @symblink LINK [DIR]
#?
#? Options:
#?   LINK   Symbol link path.
#?   [DIR]  In case of: `PWD` + DIR + LINK
#?
#? Output:
#?   Absolute file path that the symbol link referred.
#?
#? Example:
#?   mkdir -p /tmp/symblink/foo/bar/f4 \
#?       && ln -s f4 /tmp/symblink/foo/bar/f3 \
#?       && ln -s bar/f3 /tmp/symblink/foo/f2 \
#?       && ln -s foo/f2 /tmp/symblink/f1
#?   @symblink /tmp/symblink/f1
#?   # /tmp/symblink/foo/bar/f4
#?
function symblink () {
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
        symblink "${file}" "$(dirname "${link}")"
    else
        abspath "${link}"
    fi
}

@symblink "$@"

exit
