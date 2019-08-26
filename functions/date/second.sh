#? Description:
#?   Get the Second part from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @second [-S | -s] [TIMESTAMP]
#?
#? Options:
#?   [-S]          Get the second (00..60).
#?
#?                 This is the default option.
#?
#?   [-s]          Get the seconds since 1970-01-01 00:00:00 UTC (Epoch).
#?
#?   [TIMESTAMP]   Timestamp.
#?
function second () {
    xsh /date/get "%S s" "$@"
}
