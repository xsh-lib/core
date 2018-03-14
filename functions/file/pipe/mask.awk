function mask (str, list, char, fixed,   pos, start, end, mstr) {
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

    if (fixed) {
        mask_str = repeat(char, 6)
    } else {
        mask_str = repeat(char, end - start + 1)
    }

    return substr(str, 1, start - 1) mask_str substr(str, end + 1)
}

function repeat (str, times,   result) {
    result = sprintf("%" times "s", "")
    gsub(/ /, str, result)
    return result
}

{
    # set defaut mask char
    if (char == "") {
        char = "*"
    }

    # resolve field list and apply mask
    if (flist) {
        p = index(flist, "-")
        if (p) {
            fstart = substr(flist, 1, p - 1)
            fstart = fstart ? fstart : 1
            fend = substr(flist, p + 1)
            fend = fend ? fend : NF
        } else {
            fstart = fend = flist
        }

        # by field
        for (i=1;i<=NF;i++) {
            if (i > 1) {
                printf OFS
            }

            if (i >= fstart && i <= fend) {
                printf mask($i, clist, char, fixed)
            } else {
                printf $i
            }
        }
    } else {
        # by line
        print mask($0, clist, char, fixed)
    }
}
