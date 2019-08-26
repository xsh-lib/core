#? Description:
#?   Get the Date and Time parts from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @datetime [-c | -x -X | -F -T | -Dv | -r] [TIMESTAMP]
#?
#? Options:
#?   [-c]          Get the locale's representation of time and date.
#?                 FMT: `%c`
#?
#?   [-x]          Get the locale's representation of the date.
#?                 FMT: `%x`
#?
#?   [-X]          Get the locale's representation of the time.
#?                 FMT: `%x`
#?
#?   [-F]          Get the date.
#?                 FMT: `%F`, `%Y-%m-%d`: `2019-08-27`
#?
#?   [-T]          Get the time.
#?                 FMT: `%T`, `%H:%M:%S`: `01:32:09`
#?
#?   [-D]          Get the date.
#?                 FMT: `%D`, `%m/%d/%y`: `08/27/19`
#?
#?   [-v]          Get the date.
#?                 FMT: `%v`, `%e-%b-%Y`: `27-Aug-2019`
#?
#?   [-r]          Get the time (12 hour clock) with either "ante meridiem" (AM)
#?                 or "post meridiem" (PM).
#?                 FMT: `%r`, `%I:%M:%S %p`: `01:32:42 AM`
#?
#?   Default options are -F and -T.
#?
#?   [TIMESTAMP]   Timestamp.
#?
function datetime () {
    xsh /date/get "c x X %F %T D v r" "$@"
}
