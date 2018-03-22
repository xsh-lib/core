function schema () {
    local schema

    schema=${1%%://*}

    if [[ -z ${schema} || ${#schema} == ${#1} ]]; then
        echo "file"
    else
        xsh /string/lower "${schema}"
    fi
}
