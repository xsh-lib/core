#? Description:
#?   Get the Minute part from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @minute [-M] [TIMESTAMP]
#?
#? Options:
#?   [-M]          Get the minute (00..59).
#?
#?                 This is the default option.
#?
#?   [TIMESTAMP]   Timestamp.
#?
function minute () {
    xsh /date/get "%M" "$@"
}
