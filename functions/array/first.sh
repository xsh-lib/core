function first () {
    eval echo "$1[$(xsh /array/ifirst "$1")]"
    return $?
}
