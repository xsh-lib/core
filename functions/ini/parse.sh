#? Usage:
#?   @parse INI_FILE
#?
#? Options:
#?   INI_FILE  Full path of INI file to parse.
#?
#? Output:
#?   None.
#?
#? Example:
#?   cat foo.ini
#?   [my section]
#?   foo=bar
#?
#?   @parse foo.ini
#?   echo $__INI_SECTION_my_section  # 'my section'
#?   echo $__INI_VAR_my_section_foo  # 'bar'
function parse () {
    local ini_file=$1
    local kvs

    kvs=$(
        awk -F= \
            -v prefix="__INI_" '
            function trim(str) {
                gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", str); 
                return str
            }
            function get_var_name(str) {
                str=trim(str); 
                str=remove_bracket(str); 
                gsub(/[^[:alnum:]]/, "_", str); 
                return str
            }
            function remove_bracket(str) {
                gsub(/\[|\]/, "", str); 
                return str
            } 
            !/^;/ {  # filter comments
                if (match($0, /^\[.+\]$/) > 0) {  # sections
                    sv=remove_bracket($0); 
                    sn=get_var_name(sv); 
                    print prefix "SECTION_" sn "=\"" sv "\""
                } else {  # variables
                    kn=get_var_name($1); 
                    $1=""; 
                    vv=trim($0); 
                    print prefix "VAR_" sn "_" kn "=\"" vv "\""
                }
            }' "${ini_file}"
       )
    eval "$kvs"
}
