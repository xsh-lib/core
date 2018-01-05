# foo:desc:
# Copy value of variable 1 (named by $1) to variable 2 (named by $2).
# $1 can not be an Array.

# foo:usage:
# x=1
# $foo x y
#
# x[1]=1
# $foo x[1] y[1]

function copy () {
    [[ "$1" == "$2" ]] && return 9
    unset $2  # in case $2 is an array
    eval $2=\${$1}
    return $?
}
