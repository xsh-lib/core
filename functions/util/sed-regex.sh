#? Description:
#?   A compatible wrapper of sed to enable:
#?
#?     * extended (modern) regular expressions
#?
#?   If unable to enable the feature for current environment, failure will be
#?   returned.
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
        return 255
    fi
}
