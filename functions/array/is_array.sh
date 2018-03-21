function is_array () {
    [[ "$(declare -p "$1" 2>/dev/null)" =~ "declare -a" ]]
}
