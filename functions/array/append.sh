function append () {
    local __i

    if [[ $# -lt 2 ]]; then
        return 255
    fi

    for __i in $(seq 2 $#); do
        # clear IFS to avoid triming whitespace
        IFS='' read -r "$1[$(xsh /array/inext "$1")]" <<< "${!__i}" || return $?
    done
}
