function display (result, output_separator,   idx, a, last_cfr) {
    for (idx in result) {
        split(idx, a, ",")
        if (last_cfr != a[1]) {
            print ""
        }
        if (a[2] > 1) {
            printf output_separator
        }
        printf result[idx]
        last_cfr = a[1]
}

function parse_line (separator, enclosure,   pos) {
    pos = 1

    while (pos <= length($0)) {
        pos = parse_field($0, separator, enclosure, pos)
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
function parse_field (line, separator, enclosure, pos,   char) {

    while (pos <= length(line)) {
        char = substr(line, pos, 1)

        if (QUOTED) {
            if (char == enclosure) {
                if (substr(line, pos, 1) == enclosure) {
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
            if (char == enclosure) {
                QUOTED = 1
            } else if (char == separator) {
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
    parse_line(separator, enclosure)
}

END {
    display(RESULT, output_separator)
}
