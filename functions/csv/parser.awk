function parser (separator, enclosure, header) {
    result = parse_record($0, separator, enclosure)
}

function parse_record (record, separator, enclosure, pos,   result, i) {
    pos = 1

    i = 1
    while (pos <= length(record)) {
        pos = parse_field(record, separator, enclosure, i, pos)
        i++
    }

    return result
}

function parse_field (record, separator, enclosure, start, nfield, pos,   field, char, quoted) {
    quoted = 0

    while (pos <= length(record)) {
        char = substr(record, pos, 1)

        if (quoted) {
            if (char == enclosure) {
                if (substr(record, pos+1, 1) == enclosure) {
                    field = enclosure enclosure
                } else {
                    break
                }
            } else {
                field = field char
            }
        } else {
            if (char == quote) {
                quoted = 1
            }
        }
        pos++
        quoted = 0

        start = end + 1
    }

    result[NR,nfield] = substr($0, start, end - start)
    return pos
}
