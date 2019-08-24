#? Description:
#?   Get a timestamp with default format: "%Y-%m-%d %H:%M:%S"
#?
#? Usage:
#?   @timestamp [FORMAT]
#?
#? Options:
#?   [FORMAT]   Date format string without a leading `+`.
#?
function timestamp () {
    date "+${1:-${XSH_X_DATE__DATETIME_FMT:?}}"
}
