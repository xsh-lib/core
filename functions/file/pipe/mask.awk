function mask (str, list, char, fixed,   pos, start, end, mstr, result, LEN_OF_FIXED_MASK) {
    LEN_OF_FIXED_MASK = 6

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

    # resolve mask str
    if (fixed) {
        mstr = repeat(char, LEN_OF_FIXED_MASK)
    } else {
        mstr = repeat(char, end - start + 1)
    }

    # apply the mask
    result = substr(str, 1, start - 1) mstr substr(str, end + 1)

    return result
}

function repeat (str, times,   result) {
    result = sprintf("%" times "s", "")
    gsub(/ /, str, result)

    return result
}

{
    if (flist) {
        # resolve start and end field
        pos = index(flist, "-")
        if (pos) {
            fstart = substr(flist, 1, pos - 1)
            fstart = fstart ? fstart : 1
            fend = substr(flist, pos + 1)
            fend = fend ? fend : NF
        } else {
            fstart = fend = flist
        }

        # mask by field
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
        # mask by line
        print mask($0, clist, char, fixed)
    }
}
