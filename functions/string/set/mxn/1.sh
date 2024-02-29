#? Description:
#?   Generate Cartesian Product by the items of sets.
#?
#? Edition:
#?   Based on 'xargs' utility.
#?
#? Usage:
#?   @mxn [-I INPUT_DELIMITER] [-O OUTPUT_DELIMITER] [-s SIGNATURE] <SET> [...]
#?
#? Options:
#?   SET [...]               A string contains items delimited with INPUT_DELIMITER.
#?
#?   [-I INPUT_DELIMITER]    Used to separate items of input SET. Default is '\n'.
#?   [-O OUTPUT_DELIMITER]   Used to separate output items. Default is a whitespacc.
#?   [-s SIGNATURE]          Used to generate replacement marks used internally.
#?                           Default SIGNATURE is '{<N>}'.
#?                           With the default, It's generating marks from 1 to <N> where
#?                           <N> is the number of given SETs, the marks will look like:
#?                           '{1}' '{2}' ...
#?                           If the marks may appear in the output, please use -s to give
#?                           a different SIGNATURE with one literal '<N>' included.
#?
#? Example:
#?   $ @mxn -I ' ' -O '-' 'Hello World' 'Foo Bar'
#?   Hello-Foo Hello-Bar
#?   World-Foo World-Bar
#?
#? Alternation:
#?   1. Bash's Brace Expansion
#?
#?      echo {a..c}-{1..3}
#?
#?      This method:
#?      * Is very handy for the character set like [a-zA-Z0-9].
#?      * Can not use variables.
#?
#?   2. Utility: join
#?
#?      join -j -1 -o 1.1,2.1 file1 file2
#?
#?      https://stackoverflow.com/questions/23363003/how-to-produce-cartesian-product-in-bash
#?
#? Developer:
#?   I failed trying to make the input parameter SET as files.
#?   Because when pass SET files with process substitution <( ), the later file
#?   descriptors will become unvailable in the subprocess made by command substitution
#?   when doing recurvive call.
#?
function mxn () {
    declare OPTIND OPTARG opt

    # Set default
    declare INPUT_DELIMITER='\n'
    declare OUTPUT_DELIMITER=' '
    declare SIGNATURE='{<N>}'

    while getopts I:O:s: opt; do
        case $opt in
            I)
                INPUT_DELIMITER=$OPTARG
                ;;
            O)
                OUTPUT_DELIMITER=$OPTARG
                ;;
            s)
                SIGNATURE=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))


    #? Usage:
    #?   __mxn [-l LEVEL] [-o output_mark] [-P] <SET> [...]
    #?
    #? Options:
    #?   [-l LEVEL]         Used internally during recursive call. Default is 1.
    #?   [-o OUTPUT_MARK]   Used internally during recursive call.
    #?   [-P]               Enable parallel mode.
    #?
    #? Depends:
    #?   This function depends on following environment variables:
    #?
    #?   INPUT_DELIMITER
    #?   OUTPUT_DELIMITER
    #?   SIGNATURE
    #?
    #? Example:
    #?   INPUT_DELIMITER=' ' OUTPUT_DELIMITER='-' SIGNATURE='{<N>}' \
    #?   __mxn 'Hello World' 'Foo Bar'
    #?   # Hello-Foo Hello-Bar
    #?   # World-Foo World-Bar
    #?
    function __mxn () {
        declare OPTIND OPTARG opt

        # Set default
        declare level=1
        declare output_mark=${SIGNATURE//<N>/$level}
        declare -a parallel_options

        while getopts l:o:P opt; do
            case $opt in
                l)
                    level=$OPTARG
                    ;;
                o)
                    output_mark=$OPTARG
                    ;;
                P)
                    parallel_options=(
                        '-P'
                        $(xsh /sys/cpu/cores)
                    )
                    ;;
                *)
                    return 255
                    ;;
            esac
        done
        shift $((OPTIND - 1))

        # Set unlimited number of replacements for BSD version xargs
        declare maximum_replace_options=('-R' '-1')

        declare set
        if [[ $INPUT_DELIMITER == '\n' ]]; then
            set=$1
        else
            set=${1//${INPUT_DELIMITER}/$'\n'}
        fi

        if [[ $# -gt 1 ]]; then
            # 2 or more SETs left
            declare next_output_mark=${output_mark}${OUTPUT_DELIMITER}${SIGNATURE//<N>/$((level + 1))}

            # Try not to quote the command substitution: $(__mxn -l ... -o ... ...).
            # Because xargs has a limitation of 255 bytes long for each argument of utility.
            xargs "${maximum_replace_options[@]}" "${parallel_option[@]}" \
                  -I "${SIGNATURE//<N>/$level}" \
                  echo $(__mxn -l "$((level + 1))" -o "$next_output_mark" "${@:2}") \
                  <<< "$set"
        else
            # Only 1 SET left
            xargs "${maximum_replace_options[@]}" "${parallel_option[@]}" \
                  -I "${SIGNATURE//<N>/$level}" \
                  echo "$output_mark" \
                  <<< "$set"
        fi
    }

    __mxn -P "$@"
    unset -f __mxn
}
