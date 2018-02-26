function parser (separator, enclosure, header) {
    result = parse_record($0, separator, enclosure)
}

function parse_record (record, separator, enclosure,   result, pos, nfield) {
    pos = 1

    nfield = 1
    while (pos <= length(record)) {
        pos = parse_field(record, separator, enclosure, nfield, pos)
        nfield++
    }

    return result
}

function parse_field (record, separator, enclosure, nfield, pos,   field, char, quoted) {
    quoted = 0

    while (pos <= length(record)) {
        char = substr(record, pos, 1)

        if (quoted) {
            if (char == enclosure) {
                pos++
                if (substr(record, pos+1, 1) == enclosure) {
                    field = field char
                } else {
                    break
                }
            } else {
                field = field char
            }
        } else {
            if (char == enclosure) {
                quoted = 1
            }
        }
        pos++
    }

    pos++
    quoted = 0
    result[NR,nfield] = field

    return pos
}
