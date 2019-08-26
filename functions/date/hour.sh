#? Description:
#?   Get the Hour part from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @hour [-H | -I | -k | -l] [TIMESTAMP]
#?
#? Options:
#?   [-H]          Get the hour (00..23).
#?
#?                 This is the default option.
#?
#?   [-I]          Get the hour (01..12).
#?
#?   [-k]          Get the hour, space padded ( 0..23); same as %_H.
#?
#?   [-l]          Get the hour, space padded ( 0..12); same as %_I.
#?
#?   [TIMESTAMP]   Timestamp.
#?
function hour () {
    xsh /date/get "%H I k l" "$@"
}
