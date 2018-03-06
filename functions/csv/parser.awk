# Global Variables:
#   RESULT
#   CNR
#   CNF
#   FIELD
#   QUOTED
function parse (line, separator, enclosure,   pos, char) {
    pos = 1  # start at first char of line

    while (pos <= length(line)) {
        char = substr(line, pos, 1)

        if (QUOTED) {  # inside unclosed quotes
            if (char == enclosure) {
                if (substr(line, pos+1, 1) == enclosure) {  # quoted `""` means signle `"`
                    FIELD = FIELD char
                    pos++  # skip to process second `"`
                } else {
                    QUOTED = 0  # quotes closed
                }
            } else {
                FIELD = FIELD char
            }
        } else {
            if (char == enclosure) {
                QUOTED = 1  # quotes opened
            } else if (char == separator) {
                RESULT[CNR "," CNF] = FIELD
                FIELD = ""  # re-initiate field
                CNF++  # increase field number
            } else {
                FIELD = FIELD char  # allow on demand quotes in csv
            }
        }

        pos++
    }

    if (!QUOTED) {  # unquoted end of line means end of record
        RESULT[CNR "," CNF] = FIELD
        FIELD = ""
        CNR++  # increase record number
        CNF=1  # re-initiate field number
    }
}

function output_table (array, m, n, ofs,   i, j) {
    for (i=1;i<=m;i++) {
        for (j=1;j<=n;j++) {
            if (j > 1) {
                printf ofs
            }

            printf array[i "," j]

            if (j == n) {
                print ""
            }
        }
    }
}

function output_variable (array, m, n, prefix,   i, j, fn, fns, fv) {
    i = 1
    for (j=1;j<=n;j++) {
        fv = array[i "," j]
        fn = get_var_name(fv)
        fns[length(fns)+1] = fn
        print gen_variables(prefix "FIELDS_" fn, fv)
        print gen_array_variables(prefix "FIELDS_" fn "_ROWS", RESULT, 0, j)
    }
    print gen_array_variables(prefix "FIELDS", fns)
}

# Trim blankspaces of string.
#
# @param [string] str  String to trim.
# @return [string]     The string that with blankspaces trimmed.
#
function trim (str) {
    gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", str)
    return str
}

# Remove the square bracket enclosure from string.
#
# @param [string] str  String to process.
# @return [string]     The string that with square bracket enclosure removed.
#
function remove_bracket (str) {
    gsub(/^\[|\]$/, "", str)
    return str
}

# Generate a valid variable name from string.
#
# @param [string] str  String to generate from.
# @return [string]     The valid variable name generated from string.
#
function get_var_name (str) {
    str = remove_bracket(trim(str))
    gsub(/[^[:alnum:]]/, "_", str)
    return str
}

# Generate variable assignment expression name="value".
#
# @param [string] name   Variable name.
# @param [string] value  Value of variable.
# @return [string]       The variable assignment expression.
#
function gen_variables (name, value) {
    return name "=" "\047" value "\047"
}

# Generate Array variable assignment expression name=("value" "value" ...)
#
# @param [string] name    Variable name.
# @param [array] value    Value of Array variable.
# @param [int] idx        Function's private parameter.
# @param [string] result  Function's private parameter.
# @return [string]        The Array variable assignment expression.
#
function gen_array_variables (name, array, i, j,   idx, a, result) {
    result = name "=("
    for (idx in array) {
        if (i) {
            split(idx, a, ",")
            if (i == a[1]) {
                result = result "[" a[2] "]=\047" array[idx] "\047" OFS
            }
        } else if (j) {
            split(idx, a, ",")
            if (j == a[2]) {
                result = result "[" a[1] "]=\047" array[idx] "\047" OFS
            }
        } else {
            result = result "[" idx "]=\047" array[idx] "\047" OFS
        }
    }
    result = result ")"

    return result
}

BEGIN {
    CNR=1  # record number started at 1
    CNF=1  # field number started at 1
}

{
    parse($0, separator, enclosure)
}

END {
    CNR--
    CNF=length(RESULT)/CNR

    if (output == "table") {
        output_table(RESULT, CNR, CNF, table_separator)
    } else if (output == "variable") {
        output_variable(RESULT, CNR, CNF, prefix)
    }
}
