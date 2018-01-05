function inext () {
    xsh array/ilast "$1" | awk '{if ($0 != "") print $0 + 1; else print 0; }'
    return $PIPESTATUS
}
