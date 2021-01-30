#? Description:
#?   Parse the format of given timestamp.
#?
#? Usage:
#?   @parser <TIMESTAMP>
#?
#? Example:
#?   $ @parser "2008-10-10 00:00:00"
#?   %Y-%m-%d HH:MM:SS
#?
#?   $ @parser "2008-10-10"
#?   %Y-%m-%d
#?
#?   $ @parser "00:00:00"
#?   HH:MM:SS
#?
function parser () {
    declare base_dir=${XSH_HOME}/lib/x/functions/date  # TODO: use varaible instead

    # --re-interval (In short words)
    # 
    # GNU awk(used by Linux) support this option, it allows to use  `{` and ` }` in the regexp.
    # Tranditional awk(used by macOS) does not support this option.
    #
    # 2019/11/01: This option is no harm for the awk shipped with macOS.
    # 2021/01/29: No longer true, now it raises warning in STDERR(awk version 20200816 of macOS):
    #             `awk: unknown option --re-interval ignored`, but still works.
    # 
    # --re-interval (from GNU Awk 3.1.7)
    # 
    # Enable the use of interval expressions in regular expression matching (see
    # Regular Expressions, below). Interval expressions were not traditionally
    # available in the AWK language. The POSIX standard added them, to make awk
    # and egrep consistent with each other. However, their use is likely to
    # break old AWK programs, so gawk only provides them if they are requested
    # with this option, or when --posix is specified.
    #
    if xsh /util/is-compatible-awk-re-interval; then
        awk -f "${base_dir}/parser.awk" <<< "$*" --re-interval
    else
        awk -f "${base_dir}/parser.awk" <<< "$*"
    fi
}
