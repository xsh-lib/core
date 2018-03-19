#? Mark a string with SGR code in terminal.
#?
#? Parameter:
#?   str  [String]  String to mark.
#?   list [String]  The list specifies character positions.
#?   code [String]  SGR Code, more than one can be separated with semicolon ";".
#?                  Valid codes: 0~107.
#?                  Wiki: https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
#?
#? Return:
#?   [String]  Marked string.
#?
#? Output:
#?   None
#?
function mark (str, list, code,   a, pos, start, end, mstr, result) {
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
    mstr = "\033[" code "m" substr(str, begin, end) "\033[0m"

    # apply the mark
    result = substr(str, 1, start - 1) mstr substr(str, end + 1)

    return result
}

OFS=FS {
    # Wiki: https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters
    MARKER["bold"] = 1
    MARKER["faint"] = 2
    MARKER["italic"] = 3
    MARKER["underline"] = 4
    MARKER["reverse"] = 7
    MARKER["strikethrough"] = 9
    MARKER["black"] = 30
    MARKER["red"] = 31
    MARKER["green"] = 32
    MARKER["yellow"] = 33
    MARKER["blue"] = 34
    MARKER["magenta"] = 35
    MARKER["cyan"] = 36
    MARKER["white"] = 37
    MARKER["bg_black"] = 40
    MARKER["bg_red"] = 41
    MARKER["bg_green"] = 42
    MARKER["bg_yellow"] = 43
    MARKER["bg_blue"] = 44
    MARKER["bg_magenta"] = 45
    MARKER["bg_cyan"] = 46
    MARKER["bg_white"] = 47
    MARKER["bright_black"] = 90
    MARKER["bright_red"] = 91
    MARKER["bright_green"] = 92
    MARKER["bright_yellow"] = 93
    MARKER["bright_blue"] = 94
    MARKER["bright_magenta"] = 95
    MARKER["bright_cyan"] = 96
    MARKER["bright_white"] = 97
    MARKER["bg_bright_black"] = 100
    MARKER["bg_bright_red"] = 101
    MARKER["bg_bright_green"] = 102
    MARKER["bg_bright_yellow"] = 103
    MARKER["bg_bright_blue"] = 104
    MARKER["bg_bright_magenta"] = 105
    MARKER["bg_bright_cyan"] = 106
    MARKER["bg_bright_white"] = 107

    split(marker, a)
    code = sep = ""
    for (i=1;i<=length(a);i++) {
        code = code sep MARKER[a[i]]
        sep = ";"
    }

    if (pattern == "" || match($0, pattern) > 0) {
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
                    printf mark($j, clist, code)
                } else {
                    printf $j
                }
            }

            printf "\n"
        } else {
            # mark by line
            print mark($0, clist, code)
        }
    } else {
        print
    }
}
