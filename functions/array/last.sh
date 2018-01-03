function x-array-last () {
    eval echo "$1[$(xsh array/ilast "$1")]"
    return $?
}
