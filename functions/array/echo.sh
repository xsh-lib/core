# foo:desc:
# echo each item of an Array as a line.

# foo:usage:
# x=(1 2 3)
# $foo x
# 1
# 2
# 3

function echo () {
    local i
    for i in $(eval echo \${!$1[@]})
    do
        eval echo \"\${$1[$i]}\"
    done
    return $?
}
