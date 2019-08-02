#? Description:
#?   Generate Cartesian Product of sets.
#?
#? Usage:
#?   @mxn [-I INPUT_DELIMITER] [-O OUTPUT_DELIMITER] [-s SIGNATURE] <SET> [...]
#?
#? Options
#?   SET                     A string contains items delimited with INPUT_DELIMITER.
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
#?   @mxn <(seq 1 3) <(seq 4 6)
#?

function mxn () {
    local OPTIND OPTARG opt

    # Set default
    local INPUT_DELIMITER='\n'
    local OUTPUT_DELIMITER=' '
    local SIGNATURE='{<N>}'

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
    #?   __mxn [-l LEVEL] [-o output_mark] [-P] SET ...
    #?
    #? Options:
    #?   [-l LEVEL]         Default is 1.
    #?   [-o OUTPUT_MARK]   Default is
    function __mxn () {
        local OPTIND OPTARG opt

        # Set default
        local level=1
        local output_mark="${SIGNATURE//<N>/$level}"
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
        local maximum_replace_options=('-R' '-1')

        local set
        if [[ $INPUT_DELIMITER == '\n' ]]; then
            set=$1
        else
            set="${1//${INPUT_DELIMITER}/$'\n'}"
        fi

        if [[ $# -gt 1 ]]; then
            # 2 or more SETs left
            next_output_mark="${output_mark}${OUTPUT_DELIMITER}${SIGNATURE//<N>/$((level + 1))}"

            # Try not to quote the process substitution: $(__mxn -l ... -o ... ...).
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
}
