function ifirst () {
    eval echo \${!$1[@]} | awk '{print $1}'
    return $PIPESTATUS
}
