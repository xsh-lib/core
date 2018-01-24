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
#?   echo $__INI_SECTIONS_my_section  # 'my section'
#?   echo $__INI_KEYS_my_section_foo  # 'bar'
#?
#?   @parse -p __FOO_INI_ foo.ini
#?   echo $__FOO_INI_SECTIONS_my_section  # 'my section'
#?   echo $__FOO_INI_KEYS_my_section_foo  # 'bar'
#?
function parse () {
    local opt OPTIND OPTARG
    local prefix ini_file
    local kvs ln

    while getopts p: opt; do
        case ${opt} in
            p)
                prefix=${OPTARG}
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

    kvs=$(
        awk -F= \
            -v prefix="${prefix:-__INI_}" '
            function trim(str) {
                gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", str)
                return str
            }
            function remove_bracket(str) {
                gsub(/\[|\]/, "", str)
                return str
            }
            function get_var_name(str) {
                str = remove_bracket(trim(str))
                gsub(/[^[:alnum:]]/, "_", str)
                return str
            }
            function gen_variables(name, value) {
                print name "=" "\047" value "\047"
            }
            function gen_array_variables(name, array,   idx) {
                printf name "=("
                for (idx in array) {
                    printf "\047" array[idx] "\047" OFS
                }
                print ")"
            }
            !/^;/ {  # filter out commented lines
                if (match($0, /^\[.+\]$/) > 0) {  # sections
                    if (sn) {
                        gen_array_variables(prefix "KEYS_" sn, kns)
                    }
                    delete kns
                    sn = get_var_name($0)
                    sns[length(sns)+1] = sn
                    sv = remove_bracket($0)
                    gen_variables(prefix "SECTIONS_" sn, sv)
                } else {  # variables
                    kn = get_var_name($1)
                    kns[length(kns)+1] = kn
                    kv = trim($1)
                    $1 = ""
                    vv = trim($0)
                    gen_variables(prefix "KEYS_" sn "_" kn, kv)
                    gen_variables(prefix "VALUES_" sn "_" kn, vv)
                }
            }
            END {
                if (sn) {
                    gen_array_variables(prefix "KEYS_" sn, kns)
                }
                gen_array_variables(prefix "SECTIONS", sns)
            }' "${ini_file}"
       )

    source /dev/stdin <<<"$(echo "${kvs}")"
}
