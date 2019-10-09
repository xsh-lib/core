#? Description:
#?   A compatible wrapper of sed to enable:
#?
#?     * extended (modern) regular expressions
#?     * editing file in-place without backup
#?
#?   If unable to enable the features for current environment, failure will be
#?   returned.
#?
#? Usage:
#?   @sed-regex-inplace [SED_OPTIONS]
#?
function sed-regex-inplace () {
    if x-util-is-compatible-sed-r && x-util-is-compatible-i-bsd; then
        sed -r -i '' "$@"
    elif x-util-is-compatible-sed-r && x-util-is-compatible-i-gnu; then
        sed -r -i "$@"
    elif x-util-is-compatible-sed-E && x-util-is-compatible-i-bsd; then
        sed -E -i '' "$@"
    elif x-util-is-compatible-sed-E && x-util-is-compatible-i-gnu; then
        sed -E -i "$@"
    else
        return 255
    fi
}
