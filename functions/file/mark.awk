#? mark a string with style.
#?
#? Parameter:
#?   str    [String]   String to mark.
#?   list   [String]   The list specifies character positions.
#?   style  [String]   style name.
#?
#? Return:
#?   [String]  Marked string.
#?
#? Output:
#?   None
#?
function mark (str, list, style,   a, pos, start, end, mstr, result, STYLES) {
    # https://en.wikipedia.org/wiki/ANSI_escape_code
    STYLES["reset"] = 0
    STYLES["bold"] = 1
    STYLES["faint"] = 2
    STYLES["italic"] = 3
    STYLES["underline"] = 4
    STYLES["reverse"] = 7
    STYLES["strikethrough"] = 9
    STYLES["black"] = 30
    STYLES["red"] = 31
    STYLES["green"] = 32
    STYLES["yellow"] = 33
    STYLES["blue"] = 34
    STYLES["magenta"] = 35
    STYLES["cyan"] = 36
    STYLES["white"] = 37
    STYLES["bg_black"] = 40
    STYLES["bg_red"] = 41
    STYLES["bg_green"] = 42
    STYLES["bg_yellow"] = 43
    STYLES["bg_blue"] = 44
    STYLES["bg_magenta"] = 45
    STYLES["bg_cyan"] = 46
    STYLES["bg_white"] = 47
    STYLES["bright_black"] = 90
    STYLES["bright_red"] = 91
    STYLES["bright_green"] = 92
    STYLES["bright_yellow"] = 93
    STYLES["bright_blue"] = 94
    STYLES["bright_magenta"] = 95
    STYLES["bright_cyan"] = 96
    STYLES["bright_white"] = 97
    STYLES["bg_bright_black"] = 100
    STYLES["bg_bright_red"] = 101
    STYLES["bg_bright_green"] = 102
    STYLES["bg_bright_yellow"] = 103
    STYLES["bg_bright_blue"] = 104
    STYLES["bg_bright_magenta"] = 105
    STYLES["bg_bright_cyan"] = 106
    STYLES["bg_bright_white"] = 107

    # resolve pos of start and end
    if (list) {
        pos = index(list, "-")
        if (pos) {
            start = substr(list, 1, pos - 1)
            start = start ? start : 1
            end = substr(list, pos + 1)
            end = end ? end : length(str)
        } else {
            start = end = list
        }
    } else {
        start = 1
        end = length(str)
    }

    # resolve mark
    mstr = "\033[" STYLES[tolower(style)] "m" substr(str, begin, end) "\033[0m"

    # apply the mark
    result = substr(str, 1, start - 1) mstr substr(str, end + 1)

    return result
}

{
    if (flist) {
        # resolve start and end field
        split(flist, a, ",")

        for (idx in a) {
            pos = index(a[idx], "-")

            if (pos) {
                fstart = substr(a[idx], 1, pos - 1)
                fstart = fstart ? fstart : 1
                fend = substr(a[idx], pos + 1)
                fend = fend ? fend : NF
            } else {
                fstart = fend = a[idx]
            }

            for (i=fstart;i<=fend;i++) {
                farr[i] = ""
            }
        }

        # mark by field
        for (j=1;j<=NF;j++) {
            if (j > 1) {
                printf OFS
            }

            if (j in farr) {
                printf mark($j, clist, style)
            } else {
                printf $j
            }
        }

        printf "\n"
    } else {
        # mark by line
        print mark($0, clist, style)
    }
}
