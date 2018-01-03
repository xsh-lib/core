# foo:desc:
# Append a value (passed by $2) to an array (named by $1).

# foo:usage:
# x=(1 2 3)
# $foo x 4
# echo ${x[@]}
# 1 2 3 4

function x-array-append () {
    eval $1[$(xsh array/inext "$1")]=\$2
    return $?
}
