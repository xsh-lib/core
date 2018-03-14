#? Usage:
#?   @mask [-c LIST] [-f LIST] [-d DELIMITER] [-m MASK] [-x] < /dev/stdin
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
    local delimiter flist clist mask fixed
    local BASE_DIR="${XSH_HOME}/lib/x/functions/file/pipe"  # TODO: use varaible instead

    while getopts d:f:c:m:x: opt; do
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
            
    awk -F "${delimiter}" \
        -v flist=${flist} \
        -v clist=${clist} \
        -v char=${mask} \
        -v fixed=${fixed} \
        -f "${BASE_DIR}/mask.awk" < /dev/stdin
}
