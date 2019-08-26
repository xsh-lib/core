#? Description:
#?   Get the Year part from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @year [-Yy | -Gg | -C] [TIMESTAMP]
#?
#? Options:
#?   [-Y]          Get the year without century (00-99).
#?
#?                 This is the default option.
#?
#?   [-y]          Get the year with century.
#?
#?   [-G]          Get the year of ISO week number.
#?
#?   [-g]          Get the last two digits of year of ISO week number.
#?
#?   [-C]          Get the century.
#?
#?   [TIMESTAMP]   Timestamp.
#?
function year () {
    xsh /date/get "%Y y G g C" "$@"
}
