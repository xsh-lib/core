#? Usage:
#?   @mask [-d DELIMITER] [-f LIST] [-c LIST] [-m MASK] [-x] FILE
#?
#? Option:
#?   [-d DELIMITER]  Use DELIMITER as the field delimiter character instead
#?                   of the tab character.
#?
#?   [-f LIST]       The list specifies fields.
#?
#?   [-c LIST]       The list specifies character positions.
#?
#?   [-m MASK]       Mask character. Default is '*'.
#?
#?   [-x]            Use fixed length on masking string, 6 characters.
#?
#?
#? Output:
#?   Masked string from standard input.
#?
#? Example:
#?   echo 'username password' | @mask -f2 -c1-4
#?   # username ****word
#?
function mask () {
    local opt OPTIND OPTARG
    local delimiter flist clist mask fixed file
    local BASE_DIR="${XSH_HOME}/lib/x/functions/file"  # TODO: use varaible instead

    mask="*"  # set default mask char

    while getopts d:f:c:m:x opt; do
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
            m)
                mask=${OPTARG}
                ;;
            x)
                fixed=1
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
                -v flist="${flist}" \
                -v clist="${clist}" \
                -v char="${mask}" \
                -v fixed="${fixed}" \
                -f "${BASE_DIR}/mask.awk" "${file}"
        else
            awk -v flist="${flist}" \
                -v clist="${clist}" \
                -v char="${mask}" \
                -v fixed="${fixed}" \
                -f "${BASE_DIR}/mask.awk" "${file}"
        fi
    else
        if [[ -n ${delimiter} ]]; then
            awk -F "${delimiter}" \
                -v flist="${flist}" \
                -v clist="${clist}" \
                -v char="${mask}" \
                -v fixed="${fixed}" \
                -f "${BASE_DIR}/mask.awk" < /dev/stdin
        else
            awk -v flist="${flist}" \
                -v clist="${clist}" \
                -v char="${mask}" \
                -v fixed="${fixed}" \
                -f "${BASE_DIR}/mask.awk" < /dev/stdin
        fi
    fi
}
