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

#? Generate variable assignment expression name="value".
#?
#? Parameter:
#?   name  [String]  Variable name.
#?   value [String]  Value of variable.
#?
#? Return:
#?   [String]  The variable assignment expression.
#?
#? Output:
#?   None
#?
function gen_variables (name, value) {
    return name "=" "\047" value "\047"
}

#? Generate Array variable assignment expression name=([0]='element1' [1]='element2' ...)
#?
#? Parameter:
#?   name  [String]  Variable name.
#?   value [Array]   Value of Array variable.
#?
#? Return:
#?   [String]  The Array variable assignment expression.
#?
#? Output:
#?   None
#?
function gen_array_variables (name, array,   idx, result) {
    result = name "=("
    for (idx in array) {
        result = result "\047" array[idx] "\047" OFS
    }
    result = result ")"

    return result
}

#? Parse an ini file and output as shell variable declaration.
#?
#? Parameter:
#?   prefix [String]  Prefix to be used in variable name.
#?
#? Output:
#?   Generated shell variables for INI file.
#?
NF>0 && !/^;/ {  # filter out empty and commented lines
    if (match($0, /^\[.+\]$/) > 0) {  # sections
        if (sn) {
            print gen_array_variables(prefix "SECTIONS_" sn "_KEYS", kns)
        }
        delete kns
        sn = get_var_name($0)
        sns[length(sns)+1] = sn
        sv = trim($0, "[\\[\\]]")
        print gen_variables(prefix "SECTIONS_" sn, sv)
    } else {  # variables
        kn = get_var_name($1)
        kns[length(kns)+1] = kn
        kv = trim($1)
        $1 = ""
        vv = trim($0)
        print gen_variables(prefix "SECTIONS_" sn "_KEYS_" kn, kv)
        print gen_variables(prefix "SECTIONS_" sn "_VALUES_" kn, vv)
    }
}

END {
    if (sn) {
        print gen_array_variables(prefix "SECTIONS_" sn "_KEYS", kns)
    }
    print gen_array_variables(prefix "SECTIONS", sns)
}
