function global () {
    read -r "${1%%=*}" <<< "${1#*=}"
}
