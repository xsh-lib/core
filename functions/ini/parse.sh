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
#? Desription:
#?   Parse an INI file into shell environment variables.
#?   Link: https://en.wikipedia.org/wiki/INI_file
#?
#?   Below variables are set after INI file is parsed.
#?     __INI_SECTIONS: Array, variable name suffix for all sections
#?     __INI_SECTIONS_<section>: Value of <section>, without 
#?     __INI_SECTIONS_<section>_KEYS: Array, variable name suffix of all keys in <section>
#?     __INI_SECTIONS_<section>_KEYS_<key>: variable name suffix of <key> in <section>
#?     __INI_SECTIONS_<section>_VALUES_<key>: Value of <key> in <section>
#?
#? Example:
#?   foo.ini
#?     [section a]
#?     key1=1
#?     key2=2
#?
#?     [section b]
#?     key3=3
#?     key4=4
#?
#?   @parse foo.ini
#?   Following variables are set:
#?     __INI_SECTIONS=([0]="section_b" [1]="section_a")
#?     __INI_SECTIONS_section_a='section a'
#?     __INI_SECTIONS_section_a_KEYS=([0]="key2" [1]="" [2]="key1")
#?     __INI_SECTIONS_section_a_KEYS_key1=key1
#?     __INI_SECTIONS_section_a_KEYS_key2=key2
#?     __INI_SECTIONS_section_a_VALUES_key1=1
#?     __INI_SECTIONS_section_a_VALUES_key2=2
#?     __INI_SECTIONS_section_b='section b'
#?     __INI_SECTIONS_section_b_KEYS=([0]="key4" [1]="key3")
#?     __INI_SECTIONS_section_b_KEYS_key3=key3
#?     __INI_SECTIONS_section_b_KEYS_key4=key4
#?     __INI_SECTIONS_section_b_VALUES_key3=3
#?     __INI_SECTIONS_section_b_VALUES_key4=4
#?
function parse () {
    local opt OPTIND OPTARG
    local prefix ini_file

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

    source /dev/stdin <<<"$(awk \
        -F= \
        -v prefix="${prefix:-__INI_}" '
        function trim(str) {
            gsub(/^[[:blank:]]+|[[:blank:]]+$/, "", str)
            return str
        }
        function remove_bracket(str) {
            gsub(/^\[|\]$/, "", str)
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
        NF>0 && !/^;/ {  # filter out empty and commented lines
            if (match($0, /^\[.+\]$/) > 0) {  # sections
                if (sn) {
                    gen_array_variables(prefix "SECTIONS_" sn "_KEYS", kns)
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
                gen_variables(prefix "SECTIONS_" sn "_KEYS_" kn, kv)
                gen_variables(prefix "SECTIONS_" sn "_VALUES_" kn, vv)
            }
        }
        END {
            if (sn) {
                gen_array_variables(prefix "SECTIONS_" sn "_KEYS", kns)
            }
            gen_array_variables(prefix "SECTIONS", sns)
        }' "${ini_file}"
    )"
}
