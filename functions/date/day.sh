#? Description:
#?   Get the Day part from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @day [-d | -e | -j] [TIMESTAMP]
#?
#? Options:
#?   [-d]          Get the day of month (01..31).
#?
#?                 This is the default option.
#?
#?   [-e]          Get the day of month, space padded; same as %_d.
#?
#?   [-j]          Get the day of year (001..366).
#?
#?   [TIMESTAMP]   Timestamp.
#?
function day () {
    xsh /date/get "%d e j" "$@"
}
