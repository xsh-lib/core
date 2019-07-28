#? Description:
#?   A compatible wrapper for sed with extended (modern) regular expressions
#?   enabled.
#?   If unable to enable any extended regular expressions for current
#?   environment, a failure will be returned.
#?
#? Usage:
#?   @sed-regex [SED_OPTIONS]
#?
function sed-regex () {
    if x-util-is-compatible-sed-r; then
        sed -r "$@"
    elif x-util-is-compatible-sed-E; then
        sed -E "$@"
    else
        return 1
    fi
}
