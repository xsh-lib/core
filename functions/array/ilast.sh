function x-array-ilast () {
    eval echo \${!$1[@]} | awk '{print $NF}'
    return $PIPESTATUS
}
