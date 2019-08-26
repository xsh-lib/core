#? Description:
#?   Get the day of Week, from a given timestamp.
#?   If no timestamp given, then generate one.
#?
#? Usage:
#?   @week [-a | -A | -u | -U | -w | -W | -V] [TIMESTAMP]
#?
#? Options:
#?   [-a]          Get the abbreviated weekday name.
#?
#?   [-A]          Get the full weekday name.
#?
#?   [-u]          Get the weekday (Monday as the first day) (1-7).
#?
#?                 This is the default option.
#?
#?   [-w]          Get the weekday (Sunday as the first day) (0-6).
#?
#?   [-W]          Get the week number of the year (Monday as the first day) (00-53).
#?
#?   [-U]          Get the week number of the year (Sunday as the first day) (00-53).
#?
#?   [-V]          Get the week number of the year (Sunday as the first day) (01-53).
#?
#?                 ISO 8601, if the week containing January 1 has four or more days in the
#?                 new year, then it is week 1; otherwise it is the last week of the
#?                 previous year, and the next week is week 1.
#?
#?   [TIMESTAMP]   Timestamp.
#?
function week () {
    xsh /date/get "a %u w A U W V" "$@"
}
