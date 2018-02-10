#? Usage:
#?   @parser [-p PREFIX] INI_FILE
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
#?   @parser foo.ini
#?   # Following variables were set:
#?   # __INI_SECTIONS=([0]="section_b" [1]="section_a")
#?   # __INI_SECTIONS_section_a='section a'
#?   # __INI_SECTIONS_section_a_KEYS=([0]="key2" [1]="" [2]="key1")
#?   # __INI_SECTIONS_section_a_KEYS_key1=key1
#?   # __INI_SECTIONS_section_a_KEYS_key2=key2
#?   # __INI_SECTIONS_section_a_VALUES_key1=1
#?   # __INI_SECTIONS_section_a_VALUES_key2=2
#?   # __INI_SECTIONS_section_b='section b'
#?   # __INI_SECTIONS_section_b_KEYS=([0]="key4" [1]="key3")
#?   # __INI_SECTIONS_section_b_KEYS_key3=key3
#?   # __INI_SECTIONS_section_b_KEYS_key4=key4
#?   # __INI_SECTIONS_section_b_VALUES_key3=3
#?   # __INI_SECTIONS_section_b_VALUES_key4=4
#?
function parser () {
    local opt OPTIND OPTARG
    local base_dir prefix ini_file

    base_dir=$(cd "$(dirname "$0")" && pwd)

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

    source /dev/stdin <<< "$(
        awk -F '=' \
            -v prefix="${prefix:-__INI_}" \
            -f "${base_dir}/parser.awk" \
            "${ini_file}"
    )"
}
