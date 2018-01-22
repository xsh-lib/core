#? Usage:
#?   @parse [-p PREFIX] [-x] INI_FILE
#?
#? Options:
#?   [-p PREFIX]  Prefix variable name with PREFIX.
#?                Default is '__INI_'.
#?
#?   [-x]         To make variables export.
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
#?   echo $__INI_SECTIONS_my_section  # 'my section'
#?   echo $__INI_KEYS_my_section_foo  # 'bar'
#?
#?   @parse -p __FOO_INI_ foo.ini
#?   echo $__FOO_INI_SECTIONS_my_section  # 'my section'
#?   echo $__FOO_INI_KEYS_my_section_foo  # 'bar'
#?
function parse () {
    local opt OPTIND OPTARG
    local prefix declare_options ini_file
    local kv

    while getopts p:x opt; do
        case ${opt} in
            p)
                prefix=${OPTARG}
                ;;
            x)
                declare_options='-x'
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))
    ini_file=$1

    if [[ -z ${ini_file} ]]; then
        printf "ERROR: parameter 'INI_FILE' null or not set.\n" >&2
        return 255
    fi

    kv=$(
        awk -F= \
            -v prefix="${prefix:-__INI_}" '
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
            !/^;/ {  # filter commented lines
                if (match($0, /^\[.+\]$/) > 0) {  # sections
                    sv=remove_bracket($0);
                    sn=get_var_name(sv);
                    print prefix "SECTIONS_" sn "=\"" sv "\""
                } else {  # variables
                    kn=get_var_name($1);
                    $1="";
                    vv=trim($0);
                    print prefix "KEYS_" sn "_" kn "=\"" vv "\""
                }
            }' "${ini_file}"
      )

    declare ${declare_options} "{kv}"
}
