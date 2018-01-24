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
            -v SQ="'" \
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
            !/^;/ {  # filter commented lines
                if (match($0, /^\[.+\]$/) > 0) {  # sections
                    if (sn) {
                        printf prefix "KEYS_" sn "=("
                        for (i in kns) {
                            printf SQ kns[i] SQ OFS
                        }
                        print ")"
                    }
                    sn = get_var_name($0)
                    sns[length(sns)+1] = sn
                    sv = remove_bracket($0)
                    print prefix "SECTIONS_" sn "=" SQ sv SQ
                } else {  # variables
                    kn = get_var_name($1)
                    kns[length(kns)+1] = kn
                    kv = trim($1)
                    $1 = ""
                    vv = trim($0)
                    print prefix "KEYS_" sn "_" kn "=" SQ kv SQ
                    print prefix "VALUES_" sn "_" kn "=" SQ vv SQ
                }
            }
            END {
                printf prefix "SECTIONS=("
                for (i in sns) {
                    printf SQ sns[i] SQ OFS
                }
                print ")"
            }' "${ini_file}"
       )

    source /dev/stdin <<<"$(echo "${kvs}")"
}
