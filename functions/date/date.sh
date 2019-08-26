#? Description:
#?   Get the Date parts from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @date [-c | -x | -F | -D | -v] [TIMESTAMP]
#?
#? Options:
#?   [-c]          Get the locale's representation of time and date.
#?                 FMT: `%c`
#?
#?   [-x]          Get the locale's representation of the date.
#?                 FMT: `%x`
#?
#?   [-F]          Get the date.
#?                 FMT: `%F`, `%Y-%m-%d`: `2019-08-27`
#?
#?                 This is the default option.
#?
#?   [-D]          Get the date.
#?                 FMT: `%D`, `%m/%d/%y`: `08/27/19`
#?
#?   [-v]          Get the date.
#?                 FMT: `%v`, `%e-%b-%Y`: `27-Aug-2019`
#?
#?   [TIMESTAMP]   Timestamp.
#?
function date () {
    xsh /date/get "c x %F D v" "$@"
}
