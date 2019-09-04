#? Description:
#?   Regulate the presentation of given timestamp.
#?
#? Usage:
#?   @regulate <TIMESTAMP>
#?
function regulate () {
    local ts=$(xsh /string/trim "${1:?}")
    local fmt=$(xsh /date/parser "$ts")

    xsh /date/convert "$ts" "+$fmt"
}
