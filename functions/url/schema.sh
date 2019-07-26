#? Description:
#?   Extract the schema part from an URI.
#?
#?   URI: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier
#?
#? Usage:
#?   @schema URI
#?
#? Options:
#?   URI     The Uniform Resource Identifier (URI) will be used.
#?
#? Output:
#?   The schema of the URI. 
#?
#? Example:
#?   @schema https://github.com
#?   # https
#?
function schema () {
    local schema

    schema=${1%%:*}

    if [[ ${#schema} == ${#1} ]]; then
        # No colon found, not an URI, so no schema
        echo
    else
        xsh /string/lower "${schema}"
    fi
}
