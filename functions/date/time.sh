#? Description:
#?   Get the Time parts from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @time [-X | -T | -r | -R] [TIMESTAMP]
#?
#? Options:
#?   [-X]          Get the locale's representation of the time.
#?                 FMT: `%x`
#?
#?   [-T]          Get the time.
#?                 FMT: `%T`, `%H:%M:%S`: `01:32:09`
#?
#?                 This is the default option.
#?
#?   [-r]          Get the time (12 hour clock) with either "ante meridiem" (AM)
#?                 or "post meridiem" (PM).
#?                 FMT: `%r`, `%I:%M:%S %p`: `01:32:42 AM`
#?
#?   [-R]          Get the time.
#?                 FMT: `%R`, `%H:%M`: `01:32`
#?
#?   Default options are -F and -T.
#?
#?   [TIMESTAMP]   Timestamp.
#?
function time () {
    xsh /date/get "X %T r R" "$@"
}
