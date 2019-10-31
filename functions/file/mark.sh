#? Usage:
#?   @mark [-p PATTERN] [-d DELIMITER] [-f LIST] [-c LIST] [-m MARKER] FILE
#?
#? Options:
#?   [-p PATTERN]    Mark the lines matching the PATTERN.
#?
#?   [-d DELIMITER]  Use DELIMITER as the field delimiter character instead
#?                   of the tab character.
#?
#?   [-f LIST]       The list specifies fields.
#?
#?   [-c LIST]       The list specifies character positions.
#?
#?   [-m MARKER]     Marker name. Default is 'bold'.
#?
#? Output:
#?   Marked string from standard input.
#?
#? Example:
#?   $ @mark -f8 -c1-3 -m red <<< 'The word cat is inlcuded in word catalog.'
#?   The word cat is included in word \033[31mcat\033[0malog.
#?
function mark () {
    declare opt OPTIND OPTARG
    declare pattern delimiter flist clist marker file
    declare MARKERS
    declare BASE_DIR="${XSH_HOME}/lib/x/functions/file"  # TODO: use varaible instead

    while getopts p:d:f:c:m: opt; do
        case ${opt} in
            p)
                pattern=${OPTARG}
                ;;
            d)
                delimiter=${OPTARG}
                ;;
            f)
                flist=${OPTARG}
                ;;
            c)
                clist=${OPTARG}
                ;;
            m)
                marker+=( "${OPTARG}" )
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))
    file=$1

    if [[ -z ${marker[@]} ]]; then
        marker=bold
    fi

    if [[ -n ${file} ]]; then
        if [[ -n ${delimiter} ]]; then
            awk -F "${delimiter}" \
                -v pattern="${pattern}" \
                -v flist="${flist}" \
                -v clist="${clist}" \
                -v marker="${marker[*]}" \
                -f "${BASE_DIR}/mark.awk" "${file}"
        else
            awk -v pattern="${pattern}" \
                -v flist="${flist}" \
                -v clist="${clist}" \
                -v marker="${marker[*]}" \
                -f "${BASE_DIR}/mark.awk" "${file}"
        fi
    else
        if [[ -n ${delimiter} ]]; then
            awk -F "${delimiter}" \
                -v pattern="${pattern}" \
                -v flist="${flist}" \
                -v clist="${clist}" \
                -v marker="${marker[*]}" \
                -f "${BASE_DIR}/mark.awk" < /dev/stdin
        else
            awk -v pattern="${pattern}" \
                -v flist="${flist}" \
                -v clist="${clist}" \
                -v marker="${marker[*]}" \
                -f "${BASE_DIR}/mark.awk" < /dev/stdin
        fi
    fi
}
