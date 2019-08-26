#？Parse the input timestamp list.
#?
#? Sample Usage:
#?   awk -f /path/to/parser.awk timestamp_list.txt
#？
#? Output:
#?   The parsed format.
#?


#? Get last separator by index of expr.
function last_sep (iexpr) {
    if (iexpr in LAST_SEPS_PTR) return ITEMS[LAST_SEPS_PTR[iexpr]]
}

#? Get next separator by index of expr.
function next_sep (iexpr) {
    if (iexpr in NEXT_SEPS_PTR) return ITEMS[NEXT_SEPS_PTR[iexpr]]
}

#? Get last format name by index of expr.
function last_fmt_name (iexpr) {
    if (iexpr in LAST_EXPRS_PTR) return PARSED_FMT_NAMES[LAST_EXPRS_PTR[iexpr]]
}

#? %F:      %Y-%m-%d:                  2019-08-26
function is_date_format_F (expr, iexpr) {
    if (match(expr, "^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$") == 1) {
        FORMAT_NAME="date"
        return "%F"
    }
}

#? %D|%x:   %m/%d/%y:                  08/26/19
function is_date_format_D (expr, iexpr) {
    if (match(expr, "^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$") == 1) {
        FORMAT_NAME="date"
        return "%D"
    }
}

#? %v:      %e-%b-%Y:                  26-Aug-2019
function is_date_format_v (expr, iexpr,     a) {
    if (match(expr, "^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{4}$") == 1) {
        split(expr, a, "-")
        if (is_short_month(a[2], -1)) {
            FORMAT_NAME="date"
            return "%v"
        }
    }
}

#? %T|%X:   %H:%M:%S:                  23:40:50
function is_time_format_T (expr, iexpr) {
    if (match(expr, "^[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}$") == 1) {
        FORMAT_NAME="time"
        return "%T"
    }
}

#? %R:      %H:%M                      23:40
function is_time_format_R (expr, iexpr) {
    if (match(expr, "^[0-9]{1,2}:[0-9]{1,2}$") == 1) {
        FORMAT_NAME="time"
        return "%R"
    }
}

#? %p:      AM
function is_AMPM (expr, iexpr) {
    if (expr in VALID_AMPMS_PTR) {
        FORMAT_NAME="ampm"
        return "%p"
    }
}

#? %a:      Mon
function is_short_week (expr, iexpr) {
    if (expr in VALID_SHORT_WEEKS_PTR) {
        FORMAT_NAME="short_week"
        return "%a"
    }
}

#? %A:      Monday
function is_long_week (expr, iexpr) {
    if (expr in VALID_LONG_WEEKS_PTR) {
        FORMAT_NAME="long_week"
        return "%A"
    }
}

#? %b:      Jan
function is_short_month (expr, iexpr) {
    if (expr in VALID_SHORT_MONTHS_PTR) {
        FORMAT_NAME="month"
        return "%b"
    }
}

#? %B:      January
function is_long_month (expr, iexpr) {
    if (expr in VALID_LONG_MONTHS_PTR) {
        FORMAT_NAME="month"
        return "%B"
    }
}

#? %Z:      UTC
function is_timezone (expr, iexpr) {
    if ("timezone" in PARSED_FMT_NAMES_PTR) return
    if (match(expr, "^[A-Z]{3}$") == 1) {
        FORMAT_NAME="timezone"
        return "%Z"
    }
}

#? %z:      +0800
function is_timezone_offset (expr, iexpr) {
    if ("timezone" in PARSED_FMT_NAMES_PTR) return
    if (match(expr, "^[+-][0-9]{4}$") == 1) {
        FORMAT_NAME="timezone"
        return "%z"
    }
}

#? %Y:      2019
function is_year (expr, iexpr) {
    if ("year" in PARSED_FMT_NAMES_PTR) return
    if ("date" in PARSED_FMT_NAMES_PTR) return
    if (match(expr, "^[0-9]{4}$") == 1) {
        FORMAT_NAME="year"
        return "%Y"
    }
}

#? %d:      31
function is_day (expr, iexpr) {
    if ("day" in PARSED_FMT_NAMES_PTR) return
    if ("date" in PARSED_FMT_NAMES_PTR) return
    if (expr < 1 && expr > 31) return
    if (match(expr, "^[0-9]{1,2}$") == 1) {
        FORMAT_NAME="day"
        return "%d"
    }
}

#? Get format by index of expr.
#?
#? A global variable is set for the caller after the format is resolved.
#?
#?   * FORMAT_NAME=<name>
#?
function get_fmt (iexpr,     fmt) {
    expr = EXPRS[iexpr]

    fmt = is_date_format_F(expr, iexpr)
    if (fmt) return fmt

    fmt = is_date_format_D(expr, iexpr)
    if (fmt) return fmt

    fmt = is_date_format_v(expr, iexpr)
    if (fmt) return fmt

    fmt = is_time_format_T(expr, iexpr)
    if (fmt) return fmt

    fmt = is_time_format_R(expr, iexpr)
    if (fmt) return fmt

    fmt = is_AMPM(expr, iexpr)
    if (fmt) return fmt

    fmt = is_short_week(expr, iexpr)
    if (fmt) return fmt

    fmt = is_long_week(expr, iexpr)
    if (fmt) return fmt

    fmt = is_short_month(expr, iexpr)
    if (fmt) return fmt

    fmt = is_long_month(expr, iexpr)
    if (fmt) return fmt

    fmt = is_timezone(expr, iexpr)
    if (fmt) return fmt

    fmt = is_timezone_offset(expr, iexpr)
    if (fmt) return fmt

    fmt = is_year(expr, iexpr)
    if (fmt) return fmt

    fmt = is_day(expr, iexpr)
    if (fmt) return fmt
}

#? Parse the input timestamp.
#?
#? Sample Usage:
#?   __parse("2019-08-26")
#？
#? Return:
#?   The parsed format if successfully parsed the input.
#?
function __parse (line,     pos, expr, sep, char, process, iexpr, liexpr, isep, lisep, idx, item, fmt, result) {
    pos = 1  # start at first char of line

    expr = ""  # this expr
    sep = ""  # this sep

    # init array
    delete ITEMS[0]  # parsed exprs and seps
    delete EXPRS[0]  # parsed exprs
    delete SEPS[0]   # parsed seps

    delete LAST_EXPRS_PTR[0]   # revers pointers of last exprs
    delete NEXT_EXPRS_PTR[0]   # revers pointers of next exprs
    delete LAST_SEPS_PTR[0]    # revers pointers of last seps
    delete NEXT_SEPS_PTR[0]    # revers pointers of next seps

    # parse input into expressions
    while (pos <= length(line)) {
        char = substr(line, pos, 1)
        pos++

        if (char in VALID_SEPS_PTR) {
            sep = char  # get this sep
        } else {
            expr = expr char  # append this expr

            # continue to read this expr
            if (pos <= length(line)) continue
        }

        # process this expr
        if (expr) {
            iexpr = length(ITEMS)       # free index of EXPRS
            liexpr = length(EXPRS) - 1  # last index of EXPR

            # save this expr
            ITEMS[iexpr] = expr
            EXPRS[iexpr] = expr

            if (liexpr >= 0) {
                # save pointers for this expr
                NEXT_EXPRS_PTR[liexpr] = iexpr
                LAST_EXPRS_PTR[iexpr] = liexpr
            }
        }

        # process sep
        if (sep) {
            isep = length(ITEMS)      # free index of SEPS
            lisep = length(SEPS) - 1  # last index of SEP

            # save sep
            ITEMS[isep] = sep
            SEPS[isep] = sep

            if (expr && lisep >= 0) {
                # save pointers for this expr
                NEXT_SEPS_PTR[iexpr] = isep
                LAST_SEPS_PTR[iexpr] = lisep
            }
        }

        # reset expr and sep
        expr = ""
        sep = ""
    }

    # init array
    delete RESULTS[0]  # result format

    # parse expressions into formats
    for (idx=0; idx<length(ITEMS); idx++) {
        if (idx in EXPRS) {
            # get format by index of expr
            fmt = get_fmt(idx)
            if (fmt) {
                RESULTS[idx] = fmt
                PARSED_FMT_NAMES[idx] = FORMAT_NAME
                PARSED_FMT_NAMES_PTR[FORMAT_NAME] = idx
            } else {
                RESULTS[idx] = "{Expression Error: `" EXPRS[idx] "`}"
            }
        } else if (idx in SEPS) {
            RESULTS[idx] = ITEMS[idx]
        } else {
            return "Index Error: " idx
        }
    }

    # generate result
    for (idx=0; idx<length(RESULTS); idx++) {
        result = result RESULTS[idx]
    }

    return result
}

#？Parse the input timestamp.
#?
#? Sample Usage:
#?   { print parse($0) }
#？
#? Return:
#?   The parsed format if successfully parsed the input.
#?
function parse (line,     valid_seps, valid_sub_spes, valid_short_weeks, valid_long_weeks, valid_short_months, valid_long_months, idx) {
    valid_seps = " ,"  # blankspace and comma
    valid_ampms = "AM PM"
    valid_short_weeks = "Mon Tue Wed Thu Fri Sat Sun"
    valid_long_weeks = "Monday Tuesday Wednesday Thursday Friday Saturday Sunday"
    valid_short_months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
    valid_long_months = "January February March April June July August September October November December"

    split(valid_seps, VALID_SEPS, "")
    for (idx in VALID_SEPS) {
        VALID_SEPS_PTR[VALID_SEPS[idx]] = idx
    }

    split(valid_ampms, VALID_AMPMS)
    for (idx in VALID_AMPMS) {
        VALID_AMPMS_PTR[VALID_AMPMS[idx]] = idx
    }

    split(valid_short_weeks, VALID_SHORT_WEEKS)
    for (idx in VALID_SHORT_WEEKS) {
        VALID_SHORT_WEEKS_PTR[VALID_SHORT_WEEKS[idx]] = idx
    }

    split(valid_long_weeks, VALID_LONG_WEEKS)
    for (idx in VALID_LONG_WEEKS) {
        VALID_LONG_WEEKS_PTR[VALID_LONG_WEEKS[idx]] = idx
    }

    split(valid_short_months, VALID_SHORT_MONTHS)
    for (idx in VALID_SHORT_MONTHS) {
        VALID_SHORT_MONTHS_PTR[VALID_SHORT_MONTHS[idx]] = idx
    }

    split(valid_long_months, VALID_LONG_MONTHS)
    for (idx in VALID_LONG_MONTHS) {
        VALID_LONG_MONTHS_PTR[VALID_LONG_MONTHS[idx]] = idx
    }

    return __parse(line)
}

{
    fmt = parse($0)
    if (fmt) print(fmt)
}
