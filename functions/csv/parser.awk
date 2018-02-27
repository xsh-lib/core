# Global Variables:
#   RESULT
#   CNR
#   CNF
#   FIELD
#   QUOTED
function parse_line (   pos, char) {
    pos = 1

    while (pos <= length($0)) {
        char = substr($0, pos, 1)

        if (QUOTED) {
            if (char == ENCLOSURE) {
                if (substr($0, pos+1, 1) == ENCLOSURE) {
                    FIELD = FIELD char
                    pos++
                } else {
                    QUOTED = 0
                }
            } else {
                FIELD = FIELD char
            }
        } else {
            if (char == ENCLOSURE) {
                QUOTED = 1
            } else if (char == SEPARATOR) {
                RESULT[CNR "," CNF] = FIELD
                FIELD = ""
                CNF++
            } else {
                FIELD = FIELD char
            }
        }

        pos++
    }

    if (!QUOTED) {
        RESULT[CNR "," CNF] = FIELD
        FIELD = ""
        CNR++
        CNF=1
    }
}

function display (   i, j) {
    for (i=1;i<=CNR;i++) {
        for (j=1;j<=CNF;j++) {
            if (j > 1) {
                printf OUTPUT_SEPARATOR
            }

            printf RESULT[i "," j]

            if (j == CNF) {
                print ""
            }
        }
    }
}

function setenv () {
}

BEGIN {
    CNR=1
    CNF=1
}

{
    parse_line()
}

END {
    CNR--
    CNF=length(RESULT)/CNR
    display()
}
