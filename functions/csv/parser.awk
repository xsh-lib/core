function parser (separator, enclosure, header) {
    result = parse_record($0, separator, enclosure)
}

function parse_record (record, separator, enclosure,   result, start, end, i) {
    start = 1
    end = 1

    i = 1
    while (start <= length(record)) {
        end = parse_field(record, separator, enclosure, start)
        result[NR,i] = substr($0, start, end - start)
        start = end + 1
        i++
    }

    return result
}

function parse_field (record, separator, enclosure, start,   end, pos, char) {
    pos = start
    while (pos <= length(record)) {
        char=substr(record, pos, 1)

        if (char == separator) return pos
        if (char == quote) quoted = 1
            quoted = 0

    
}
