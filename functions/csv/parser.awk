function display (   idx, a, last_cfr) {
    for (idx in RESULT) {
        split(idx, a, ",")
        if (last_cfr != a[1]) {
            print ""
        }
        if (a[2] > 1) {
            printf OUTPUT_SEPARATOR
        }
        printf RESULT[idx]
        last_cfr = a[1]
    }
}

function parse_line (   pos) {
    pos = 1

    while (pos <= length($0)) {
        pos = parse_field($0, pos)
        CNF++
    }

    if (!QUOTED) {
        CNR++
    }
}

# Global Variables:
#   RESULT
#   CNR
#   CNF
#   FIELD
#   QUOTED
function parse_field (line, pos,   char) {

    while (pos <= length(line)) {
        char = substr(line, pos, 1)

        if (QUOTED) {
            if (char == ENCLOSURE) {
                if (substr(line, pos, 1) == ENCLOSURE) {
                    FIELD = FIELD char
                    pos++
                } else {
                    QUOTED = 0
                    RESULT[CNR,CNF] = FIELD
                    FIELD = ""
                    CNF++
                }
            } else {
                FIELD = FIELD char
            }
        } else {
            if (char == ENCLOSURE) {
                QUOTED = 1
            } else if (char == SEPARATOR) {
                # do nothing
            } else {
                # error
                return 255
            }
        }

        pos++
    }

    return pos
}

{
    CNR=1
    CNF=1
    parse_line()
}

END {
    display()
}
