#？Parse a line of csv file.
#?
#? Sample Usage:
#?   BEGIN {parse($0, ",", """")} END {for (i=1;i<=CNR;i++) {for (j=i;j<=CNF;j++) {printf RESULT[i "," j] OFS}; printf "\n"}}
#？
#? Paramater:
#?   line      [String]  A line of csv file.
#?   separator [String]  The character that used as field delimiter.
#?   between   [String]  The character that used to enclose field.
#?
#? Variable:
#?   RESULT [Array]  Store parsed csv field, use `m,n` as array index
#?                    to simulate a two dimensional array.
#?   CNR    [Int]    Number of record in csv.
#?   CNF    [Int]    Number of field for each record in csv.
#?
#? Return:
#?   None
#?
#? Output:
#?   None
#?
function parse (line, separator, between,   pos, char) {
    pos = 1  # start at first char of line

    if (!CNR) {
        CNR = 0
    }

    if (!QUOTED) {  # unquoted begin of line means begin of record
        FIELD = ""
        CNR++  # increase record number
        CNF=1  # re-initialize field number
    }

    while (pos <= length(line)) {
        char = substr(line, pos, 1)

        if (QUOTED) {  # inside unclosed quotes
            if (char == between) {
                if (substr(line, pos+1, 1) == between) {
                    # a pair of between characters were escaped
                    FIELD = FIELD char
                    pos++  # skip to process second between character
                } else {
                    QUOTED = 0  # quotes closed
                }
            } else {
                FIELD = FIELD char
            }
        } else {
            if (char == between) {
                QUOTED = 1  # quotes opened
            } else if (char == separator) {
                RESULT[CNR "," CNF] = FIELD
                FIELD = ""  # re-initialize field
                CNF++  # increase field number
            } else {
                FIELD = FIELD char  # allow on demand quotes in csv
            }
        }

        pos++
    }

    if (!QUOTED) {
        # unquoted end of line means end of field as well as record
        RESULT[CNR "," CNF] = FIELD
    }
}

#? Output a simulated two dimensional array as table.
#?
#? Paramater:
#?   array [Array]  Array to be output.
#?   m     [Int]    Number of record in the array.
#?   n     [Int]    Number of field for each record in the array.
#?   ofs   [String] Field separator for output.
#?
#? Return:
#?   None
#?
#? Output:
#?   Array as table.
#?
function output_table (array, m, n, ofs,   i, j) {
    for (i=1;i<=m;i++) {
        for (j=1;j<=n;j++) {
            if (j > 1) {
                printf ofs
            }
            printf array[i "," j]
        }
        printf "\n"
    }
}

#? Output a simulated two dimensional array as Shell variable declaration.
#?
#? Paramater:
#?   array  [Array]  Array to be output.
#?   m      [Int]    Number of record in the array.
#?   n      [Int]    Number of field for each record in the array.
#?   prefix [String] Prefix for variable name.
#?
#? Return:
#?   None
#?
#? Output:
#?   Array as Shell variable declaration.
#?
function output_variable (array, m, n, prefix, quote, single,   i, j, fn, fns, fv) {
    i = 1
    for (j=1;j<=n;j++) {
        fv = array[i "," j]
        fn = get_var_name(fv)
        fns[length(fns)+1] = fn
        print gen_variables(prefix "FIELDS_" fn, fv, quote)
        print gen_array_variables(prefix "FIELDS_" fn "_ROWS", RESULT, 0, j, quote, single)
    }
    print gen_array_variables(prefix "FIELDS", fns, 0, 0, quote, single)
}

#? Trim blankspaces of string.
#?
#? Parameter:
#?   str  [String]  String to trim.
#?   char [String]  String to be trimmed, default is [[:blank:]]
#?
#? Return:
#?   [String]  The string that with `char` trimmed.
#?
#? Output:
#?   None
#?
function trim (str, char,   regex) {
    if (char == "") {
        char = "[[:blank:]]"
    }
    regex = "^" char "+|" char "+$"
    gsub(regex, "", str)
    return str
}

#? Generate a valid variable name from string.
#?
#? Parameter:
#?   str [String]  String to generate from.
#?
#? Return:
#?   [String]  The valid variable name generated from string.
#?
#? Output:
#?   None
#?
function get_var_name (str) {
    str = trim(str)
    str = trim(str, "[\\[\\]]")
    gsub(/[^[:alnum:]]/, "_", str)
    return str
}

#? Generate variable assignment expression name=value.
#?
#? Parameter:
#?   name  [String]   Variable name.
#?   value [String]   Value of variable.
#?   quote [Integer]  If set quote=1, value will be quoted.
#?
#? Return:
#?   [String]  The variable assignment expression.
#?
#? Output:
#?   None
#?
function gen_variables (name, value, quote) {
    if (quote) {
        return name "=" "\047" value "\047"
    } else {
        return name "=" value
    }
}

#? Generate Array variable assignment expression name=[0]=element1 name[1]=element2 ...
#?
#? Parameter:
#?   name   [String]   Variable name.
#?   value  [Array]    Value of Array variable.
#?   i      [Int]      Rows i only, started at 1, 0 means all.
#?   j      [Int]      Column j only, started at 1, 0 means all.
#?   quote  [Integer]  If set quote=1, value will be quoted.
#?   single [Integer]  If set single=1, will generate single assignment expression.
#?                     Looks like: name=([0]=element1 [1]=element2 ...)
#?
#? Return:
#?   [String]  The Array variable assignment expression.
#?
#? Output:
#?   None
#?
function gen_array_variables (name, array, i, j, quote, single,   idx, sep, SEP, key, KEY, a, gen, result) {
    if (single) {
        KEY = ""
        result = name "=("
        sep = ""
        SEP = OFS
    } else {
        KEY = name
        result = ""
        sep = ""
        SEP = RS
    }

    for (idx in array) {
        gen = 0

        if (i) {
            split(idx, a, ",")

            if (i == a[1]) {
                key =  KEY "[" a[2]-1 "]"
                gen = 1
            }
        } else if (j) {
            split(idx, a, ",")

            if (j == a[2]) {
                key = KEY "[" a[1]-1 "]"
                gen = 1
            }
        } else {
            key = KEY "[" idx-1 "]"
            gen = 1
        }

        if (gen) {
            result = result sep gen_variables(key, array[idx], quote)
            sep = SEP
        }
    }

    if (single) {
        result = result ")"
    }

    return result
}

#？Parse a csv file and output as table or shell variable declaration.
#?
#? Sample Usage:
#?   awk -v separator=',' -v between='"' -v output=table -f /path/to/parser.awk sample.csv
#？
#? Paramater:
#?   separator       [String]   The character that used as field delimiter in csv file.
#?   between         [String]   The character that used to enclose field in csv file.
#?   output          [String]   Output type, could be one of `table` and `variable`.
#?   table_separator [String]   The character that used as field delimiter in output.
#?   prefix          [String]   Prefix for variable name.
#?   quote           [Integer]  If set quote=1, value will be quoted.
#?   single          [Integer]  If set single=1, will generate single assignment expression.
#?
#? Output:
#?   The parsed result or shell variables.
#?
{
    parse($0, separator, between)
}

END {
    if (output == "table") {
        output_table(RESULT, CNR, CNF, table_separator)
    } else if (output == "variable") {
        output_variable(RESULT, CNR, CNF, prefix, quote, single)
    }
}
