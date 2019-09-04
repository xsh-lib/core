#? Description:
#?   Regulate the presentation of given timestamp.
#?
#? Usage:
#?   @regulate <TIMESTAMP>
#?
#? Example:
#?   $ @regulate 'Feb 29 1900'
#?   Mar 01 1900
#?
#?   $ @regulate 2012-1-1
#?   2012-01-01
#?
function regulate () {
    local ts=$(xsh /string/trim "${1:?}")
    local fmt=$(xsh /date/parser "$ts")

    xsh /date/convert "$ts" "+$fmt"
}
