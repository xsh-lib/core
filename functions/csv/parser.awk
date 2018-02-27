# Global Variables:
#   RESULT
#   CNR
#   CNF
#   FIELD
#   QUOTED
function parse (line, separator, enclosure,   pos, char) {
    pos = 1

    while (pos <= length(line)) {
        char = substr(line, pos, 1)

        if (QUOTED) {
            if (char == enclosure) {
                if (substr(line, pos+1, 1) == enclosure) {
                    FIELD = FIELD char
                    pos++
                } else {
                    QUOTED = 0
                }
            } else {
                FIELD = FIELD char
            }
        } else {
            if (char == enclosure) {
                QUOTED = 1
            } else if (char == separator) {
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

function output_table (arr, ofs,   i, j) {
    for (i=1;i<=CNR;i++) {
        for (j=1;j<=CNF;j++) {
            if (j > 1) {
                printf ofs
            }

            printf arr[i "," j]

            if (j == CNF) {
                print ""
            }
        }
    }
}

function output_setenv (arr, prefix) {
}

BEGIN {
    CNR=1
    CNF=1
}

{
    parse($0, separator, enclosure)
}

END {
    CNR--
    CNF=length(RESULT)/CNR

    if (output == "table") {
        output_table(RESULT, table_separator)
    } else if (output == "setenv") {
        output_setenv(RESULT, prefix)
    }
}
