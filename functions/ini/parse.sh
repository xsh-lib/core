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
#?   echo $__ini_my_section  # 'my section'
#?   echo $__ini_my_section_foo  # 'bar'
function parse () {
    local ini_file=$1
    local kvs

    kvs=$(
        awk -F= \
            -v prefix="__ini_" '
            function trim(str) {
                gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", str); 
                return str
            }
            function fixname(str) {
                str=trim(str); 
                str=remove_bracket(str); 
                gsub(/[^[:alnum:]]/, "_", str); 
                return str
            }
            function remove_bracket(str) {
                gsub(/\[|\]/, "", str); 
                return str
            } 
            !/^;/ {
                if (match($0, /^\[.+\]$/) > 0) {
                    sv=remove_bracket($0); 
                    sn=fixname(sv); 
                    print prefix sn "=" sv
                } else {
                    kn=fixname($1); 
                    $1=""; 
                    vv=trim($0); 
                    print prefix sn "_" kn "=\"" vv "\""
                }
            }' "${ini_file}"
       )
    eval "$kvs"
}
