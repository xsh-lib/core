#? Description:
#?   Get the Month part from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @month [-B | -b | -m ] [TIMESTAMP]
#?
#? Options:
#?   [-B]          Get the locale's representation of the full month name.
#?
#?   [-b]          Get the locale's representation of the abbreviated month name.
#?
#?   [-m]          Get the month (01..12).
#?
#?                 This is the default option.
#?
#?   [TIMESTAMP]   Timestamp.
#?
function month () {
    xsh /date/get "B b %m" "$@"
}
