#? Usage:
#?   @mark [-d DELIMITER] [-f LIST] [-c LIST] [-s STYLE] FILE
#?
#? Option:
#?   [-d DELIMITER]  Use DELIMITER as the field delimiter character instead
#?                   of the tab character.
#?
#?   [-f LIST]       The list specifies fields.
#?
#?   [-c LIST]       The list specifies character positions.
#?
#?   [-s STYLE]      Style name.
#?
#?
#? Output:
#?   Marked string from standard input.
#?
#? Example:
#?   echo 'The word cat is inlcuded in word catalog.' | @mark -f8 -c1-3 -s bold
#?   # The word cat is included in word \033[3mcat\033[0malog.
#?
function mark () {
    local opt OPTIND OPTARG
    local delimiter flist clist style file
    local BASE_DIR="${XSH_HOME}/lib/x/functions/file"  # TODO: use varaible instead

    while getopts d:f:c:s: opt; do
        case ${opt} in
            d)
                delimiter=${OPTARG}
                ;;
            f)
                flist=${OPTARG}
                ;;
            c)
                clist=${OPTARG}
                ;;
            s)
                style=${OPTARG}
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))
    file=$1

    if [[ -n ${file} ]]; then
        if [[ -n ${delimiter} ]]; then
            awk -F "${delimiter}" \
                -v flist=${flist} \
                -v clist=${clist} \
                -v style=${style} \
                -f "${BASE_DIR}/mark.awk" "${file}"
        else
            awk -v flist=${flist} \
                -v clist=${clist} \
                -v style=${style} \
                -f "${BASE_DIR}/mark.awk" "${file}"
        fi
    else
        if [[ -n ${delimiter} ]]; then
            awk -F "${delimiter}" \
                -v flist=${flist} \
                -v clist=${clist} \
                -v style=${style} \
                -f "${BASE_DIR}/mark.awk" < /dev/stdin
        else
            awk -v flist=${flist} \
                -v clist=${clist} \
                -v style=${style} \
                -f "${BASE_DIR}/mark.awk" < /dev/stdin
        fi
    fi
}
