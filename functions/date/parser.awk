function last_expr(expr) {
    if (expr in last_expr_ptrs) return ITEMS[last_expr_ptrs[expr]]
}

function next_expr(expr) {
    if (expr in next_expr_ptrs) return ITEMS[next_expr_ptrs[expr]]
}

function last_sep(expr) {
    if (expr in last_sep_ptrs) return ITEMS[last_sep_ptrs[expr]]
}

function next_sep(expr) {
    if (expr in next_sep_ptrs) return ITEMS[next_sep_ptrs[expr]]
}

function last_fmt(expr) {
    if (expr in last_expr_ptrs) return RESULTS[last_expr_ptrs[expr]]
}


function is_short_week(expr) {
    if (! expr in SHORT_WEEK) return
    return "%a"
}

function is_long_week(expr) {
    if (! expr in LONG_WEEK) return
    return "%A"
}

function is_short_month(expr) {
    if (! expr in SHORT_MONTH) return
    return "%b"
}

function is_long_month(expr) {
    if (! expr in LONG_MONTH) return
    return "%B"
}

function is_timezone(expr) {
    if (! expr in TIMEZONE) return
    return "%?"
}

function is_year(expr) {
    if ("%Y" in parsed_fmts) return
    if (match(expr, "^[0-9]+$") == 0) return
    if (length(expr) != 4) return
    return "%Y"
}

function is_month(expr) {
    if ("%m" in parsed_fmts) return
    if (match(expr, "^[0-9]+$") == 0) return
    if (length(expr) != 2) return
    if (expr < 1 && expr > 12) return
    return "%m"
}

function is_day(expr) {
    if ("%d" in parsed_fmts) return
    if (match(expr, "^[0-9]+$") == 0) return
    if (length(expr) != 2) return
    if (expr < 1 && expr > 31) return
    return "%d"
}

function is_hour(expr) {
    if ("%H" in parsed_fmts) return
    if (match(expr, "^[0-9]+$") == 0) return
    if (length(expr) != 2) return
    if (expr < 0 && expr > 23) return
    if ( (last_sep(expr) && last_sep(expr) != " ") ||
         (next_sep(expr) && next_sep(expr) != ":") ) return
    return "%H"
}

function is_minute(expr) {
    if ("%M" in parsed_fmts) return
    if (match(expr, "^[0-9]+$") == 0) return
    if (length(expr) != 2) return
    if (expr < 0 && expr > 59) return
    if ( (last_sep(expr) && last_sep(expr) != ":") ||
         (next_sep(expr) && next_sep(expr) != ":") ) return
    if (last_fmt(expr) && last_expr != "%H") return
    return "%M"
}

function is_second(expr) {
    if ("%S" in parsed_fmts) return
    if (match(expr, "^[0-9]+$") == 0) return
    if (length(expr) != 2) return
    if (expr < 0 && expr > 59) return
    if (last_sep(expr) && last_sep(expr) != ":") return
    if (last_fmt(expr) && last_expr != "%M") return
    return "%S"
}

function get_fmt(expr,     fmt) {
    while (1) {
        fmt = is_short_week(expr)
        if (fmt) break

        fmt = is_long_week(expr)
        if (fmt) break

        fmt = is_short_month(expr)
        if (fmt) break

        fmt = is_long_month(expr)
        if (fmt) break

        fmt = is_timeone(expr)
        if (fmt) break

        fmt = is_hour(expr)
        if (fmt) break

        fmt = is_minute(expr)
        if (fmt) break

        fmt = is_second(expr)
        if (fmt) break

        fmt = is_year(expr)
        if (fmt) break

        fmt = is_month(expr)
        if (fmt) break

        fmt = is_day(expr)
        if (fmt) break

        return "error"
    }

    return fmt
}

#？Parse the input timestamp.
#?
#? Sample Usage:
#?   {parse($0)}
#？
#? Output:
#?   The parsed format if successfully parsed the input.
#?
function parse (line,     pos, expr, char, sep, len_of_expr, idx, last_expr, last_sep, item, fmt) {
    pos = 1  # start at first char of line
    expr = ""

    # init array
    delete EXPRS[0]
    delete ITEMS[0]  # exprs and separators

    while (pos <= length(line)) {
        char = substr(line, pos, 1)

        if (char in SEP) {
            sep = char
            len_of_expr = length(expr)

            if (len_of_expr == 0) {
                continue
            }

            # process expr
            idx = length(ITEMS)

            ITEMS[idx] = expr
            EXPRS[idx] = expr
            ITEM_PTRS[expr] = idx

            if (last_expr) {
                NEXT_EXPR_PTRS[last_expr] = idx
                LAST_EXPR_PTRS[expr] = ITEM_PTRS[last_expr]
            }

            # process sep
            idx = length(ITEMS)

            ITEMS[idx] = sep
            SEPS[idx] = sep

            if (last_sep) {
                NEXT_SEP_PTRS[last_sep] = idx
                LAST_SEP_PTRS[sep] = ITEM_PTRS[last_sep]
            }

            # remember last
            last_sep = sep
            last_expr = expr

            # re-initialize expr
            expr = ""
        } else {
            expr = expr char
        }

        pos++
    }

    # init array
    delete RESULTS[0]

    for (idx in ITEMS) {
        item = ITEMS[idx]

        if (idx in EXPRS) {
            fmt = get_fmt(item)
            RESULTS[idx] = fmt
            PARSED_FMTS[fmt]
            printf fmt
        } else if (idx in SEPS) {
            RESULTS[idx] = item
            printf item
        } else {
            return "error"
        }
    }

    print ""
}

#？Parse a file.
#?
#? Sample Usage:
#?   awk -f /path/to/parser.awk timestamp_list.txt
#？
#? Output:
#?   The parsed format.
#?
{
    SEP[" "]
    SEP["-"]
    SEP["/"]
    SEP[":"]
    SEP[","]
    TIMEZONE["UTC"]
    TIMEZONE["CST"]

    SHORT_WEEK_STR = "Mon Tue Wed Thu Fri Sat Sun"
    split(SHORT_WEEK_STR, arr)
    for (x in arr) SHORT_WEEK[arr[x]]

    LONG_WEEK_STR = "Monday Tuesday Wednesday Thursday Friday Saturday Sunday"
    split(LONG_WEEK_STR, arr)
    for (x in arr) LONG_WEEK[arr[x]]

    SHORT_MONTH_STR = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
    split(SHORT_MONTH_STR, arr)
    for (x in arr) SHORT_MONTH[arr[x]]

    LONG_MONTH_STR = "January February March April June July August September October November December"
    split(LONG_MONTH_STR, arr)
    for (x in arr) LONG_MONTH[arr[x]]

    parse($0)
}
