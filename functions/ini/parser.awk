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
function gen_array_variables (name, array,   idx, result) {
    result = name "=("
    for (idx in array) {
        result += "\047" array[idx] "\047" OFS
    }
    result += ")"

    return result
}

# Main
#
# @param [string] prefix  Prefix to be used in variable name.
# @output [string]        Generated shell variables for INI file.
#
NF>0 && !/^;/ {  # filter out empty and commented lines
    if (match($0, /^\[.+\]$/) > 0) {  # sections
        if (sn) {
            print gen_array_variables(prefix "SECTIONS_" sn "_KEYS", kns)
        }
        delete kns
        sn = get_var_name($0)
        sns[length(sns)+1] = sn
        sv = remove_bracket($0)
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
