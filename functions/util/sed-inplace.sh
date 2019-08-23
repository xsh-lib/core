#? Description:
#?   A compatible wrapper of sed to enable:
#?
#?     * editing file in-place without backup
#?
#?   If unable to enable the feature for current environment, failure will be
#?   returned.
#?
#? Usage:
#?   @sed-inplace [SED_OPTIONS]
#?
function sed-inplace () {
    if x-util-is-compatible-sed-i-bsd; then
        sed -i '' "$@"
    elif x-util-is-compatible-sed-i-gnu; then
        sed -i "$@"
    else
        return 255
    fi
}
