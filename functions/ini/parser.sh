#? Desription:
#?   Parse an INI file into shell environment variables.
#?
#?   If set -a, below variables are set after INI file is parsed.
#?     __INI_SECTIONS: Array, variable name suffix for all sections
#?     __INI_SECTIONS_<section>: Value of <section>, without
#?     __INI_SECTIONS_<section>_KEYS: Array, variable name suffix of all keys in <section>
#?     __INI_SECTIONS_<section>_KEYS_<key>: variable name suffix of <key> in <section>
#?     __INI_SECTIONS_<section>_VALUES_<key>: Value of <key> in <section>
#?
#? Usage:
#?   @parser [-a] [-p PREFIX] [-q] [-s] INI_FILE
#?
#? Options:
#?   [-a]         Apply the environment variables.
#?                With -a enabled, output is turned off, and -s and -q are ignored.
#?
#?   [-p PREFIX]  Prefix variable name with PREFIX.
#?                Default is '__INI_'.
#?
#?   [-q]         Enable quotes in output, value will be quoted.
#?
#?   [-s]         Enable signle mode in output, generate single expression for array
#?                assignment.
#?
#?   INI_FILE     Full path of INI file to parse.
#?
#? Output:
#?   Shell environment variables expression.
#?
#? Standard:
#?   https://en.wikipedia.org/wiki/INI_file
#?
#? Example:
#?   $ cat foo.ini
#?   [section a]
#?   key1=1
#?   key2=2
#?
#?   [section b]
#?   key3=3
#?   key4=4
#?
#?   $ @parser -a foo.ini; set | grep ^__INI_
#?   __INI_SECTIONS=([0]="section_a" [1]="section_b")
#?   __INI_SECTIONS_section_a='section a'
#?   __INI_SECTIONS_section_a_KEYS=([0]="key1" [1]="key2")
#?   __INI_SECTIONS_section_a_KEYS_key1=key1
#?   __INI_SECTIONS_section_a_KEYS_key2=key2
#?   __INI_SECTIONS_section_a_VALUES_key1=1
#?   __INI_SECTIONS_section_a_VALUES_key2=2
#?   __INI_SECTIONS_section_b='section b'
#?   __INI_SECTIONS_section_b_KEYS=([0]="key3" [1]="key4")
#?   __INI_SECTIONS_section_b_KEYS_key3=key3
#?   __INI_SECTIONS_section_b_KEYS_key4=key4
#?   __INI_SECTIONS_section_b_VALUES_key3=3
#?   __INI_SECTIONS_section_b_VALUES_key4=4
#?
function parser () {
    declare opt OPTIND OPTARG
    declare apply prefix quote single ini_file
    declare ln
    declare BASE_DIR=${XSH_HOME:?}/lib/x/functions/ini  # TODO: use varaible instead

    while getopts ap:qs opt; do
        case ${opt} in
            a)
                apply=1
                ;;
            p)
                prefix=${OPTARG}
                ;;
            q)
                quote=1
                ;;
            s)
                single=1
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

    prefix=${prefix:-__INI_}

    if [[ ${apply} ]]; then
        while read ln; do
            xsh /string/global "${ln}"
        done <<< "$(
             awk -v prefix="${prefix}" \
                 -f "${BASE_DIR}/parser.awk" \
                 "${ini_file}"
             )"
    else
        awk -v prefix="${prefix}" \
            -v quote="${quote}" \
            -v single="${single}" \
            -f "${BASE_DIR}/parser.awk" \
            "${ini_file}"
    fi
}
