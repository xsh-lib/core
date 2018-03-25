#? Trim blankspaces of string.
#?
#? Parameter:
#?   str [String]  String to trim.
#?
#? Return:
#?   [String]  The string that with blankspaces trimmed.
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
function gen_variables (name, value, quote,   Q) {
    if (quote) {
        Q = "\047"
    } else {
        Q = ""
    }

    return name "=" Q value Q
}

#? Generate Array variable assignment expression name[0]=element1 name[1]=element2 ...
#?
#? Parameter:
#?   name   [String]   Variable name.
#?   value  [Array]    Value of Array variable.
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
function gen_array_variables (name, array, quote, single,   i, sep, result) {
    if (single) {
        result = name "=("
    } else {
        result = ""
    }

    sep = ""
    for (i=1;i<=length(array);i++) {
        if (single) {
            result = result sep gen_variables("[" i-1 "]", array[i], quote)
            sep = OFS
        } else {
            result = result sep gen_variables(name "[" i-1 "]", array[i], quote)
            sep = RS
        }
    }

    if (single) {
        result = result ")"
    }

    return result
}

#? Parse an ini file and output as shell variable declaration.
#?
#? Parameter:
#?   prefix [String]   Prefix to be used in variable name.
#?   quote  [Integer]  If set quote=1, value will be quoted.
#?   single [Integer]  If set single=1, will generate single assignment expression.
#?
#? Output:
#?   [String]  Generated shell variables for INI file.
#?
NF>0 && !/^;/ {  # filter out empty and commented lines
    FS = "="

    if (match($0, /^\[.+\]$/) > 0) {  # sections
        if (sn) {
            print gen_array_variables(prefix "SECTIONS_" sn "_KEYS", kns, quote, single)
        }
        delete kns
        sn = get_var_name($0)
        sns[length(sns)+1] = sn
        sv = trim($0, "[\\[\\]]")
        print gen_variables(prefix "SECTIONS_" sn, sv, quote)
    } else {  # variables
        kn = get_var_name($1)
        kns[length(kns)+1] = kn
        kv = trim($1)
        $1 = ""
        vv = trim($0)
        print gen_variables(prefix "SECTIONS_" sn "_KEYS_" kn, kv, quote)
        print gen_variables(prefix "SECTIONS_" sn "_VALUES_" kn, vv, quote)
    }
}

END {
    if (sn) {
        print gen_array_variables(prefix "SECTIONS_" sn "_KEYS", kns, quote, single)
    }
    print gen_array_variables(prefix "SECTIONS", sns, quote, single)
}
