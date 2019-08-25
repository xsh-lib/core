#? Description:
#?   Parse the format of given timestamp.
#?
#? Usage:
#?   @parser [yyyy-mm-dd] [HH:MM:SS]
#?
#? Example:
#?   @parser "2008-10-10 00:00:00"
#?   %Y-%m-%d HH:MM:SS
#?
#?   @parser "2008-10-10"
#?   %Y-%m-%d
#?
#?   @parser "00:00:00"
#?   HH:MM:SS
#?
function parser () {
    local base_dir="${XSH_HOME}/lib/x/functions/date"  # TODO: use varaible instead

    awk -f "${base_dir}/parser.awk" <<< "$(echo "$*")"
}
