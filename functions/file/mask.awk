#? Mask a string with mask character.
#?
#? Parameter:
#?   str   [String]   String to mask.
#?   list  [String]   The list specifies character positions.
#?   char  [String]   Mask character.
#?   fixed [Integer]  Use fixed length on masking string, 6 characters.
#?
#? Return:
#?   [String]  Masked string.
#?
#? Output:
#?   None
#?
function mask (str, list, char, fixed,   a, pos, start, end, mstr, result, LEN_OF_FIXED_MASK) {
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

#? Repeat a string n times.
#?
#? Parameter:
#?   str   [String]   String to repeat.
#?   times [Integer]  Repeat n times, default is 1, means no repeat.
#?
#? Return:
#?   [String]  Concatenation of n strings.
#?
#? Output:
#?   None
#?
function repeat (str, times,   result) {
    if (times == "") {
        times = 1
    }

    result = sprintf("%" times "s", "")
    gsub(/ /, str, result)

    return result
}

OFS=FS {
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

        # mask by field
        for (j=1;j<=NF;j++) {
            if (j > 1) {
                printf OFS
            }

            if (j in farr) {
                printf mask($j, clist, char, fixed)
            } else {
                printf $j
            }
        }

        printf "\n"
    } else {
        # mask by line
        print mask($0, clist, char, fixed)
    }
}
