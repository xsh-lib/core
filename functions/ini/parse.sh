#? Usage:
#?   @parse [-p PREFIX] INI_FILE
#?
#? Options:
#?   [-p PREFIX]  Prefix variable name with PREFIX.
#?                Default is '__INI_'.
#?
#?   INI_FILE     Full path of INI file to parse.
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
#?
#?   @parse -p __INI_FOO_ foo.ini
#?   echo $__INI_FOO_SECTION_my_section  # 'my section'
#?   echo $__INI_FOO_VAR_my_section_foo  # 'bar'
#?
function parse () {
    local opt OPTIND OPTARG
    local prefix ini_file
    local kvs

    while getopts p: opt; do
        case $opt in
            p)
                prefix=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))
    ini_file=$1

    if [[ -z $ini_file ]]; then
        printf "ERROR: parameter 'INI_FILE' null or not set."
    fi

    prefix=${prefix:-__INI_}

    kvs=$(
        awk -F= \
            -v prefix="$prefix" '
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
