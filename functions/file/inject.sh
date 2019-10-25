#? Description:
#?   Inject content into file.
#?
#? Usage:
#?   @inject
#?     -c CONTENT
#?     -p <begin | end | after | before>
#?     [-e REGEX]
#?     [-m MARK_BEGIN]
#?     [-n MARK_END]
#?     [-x REGEX_MARK_BEGIN]
#?     [-y REGEX_MARK_END]
#?     FILE
#?
#? Options:
#?   -c CONTENT
#?
#?   Content to inject.
#?
#?   -p <begin | end | after | before>
#?
#?   Position to inject in the FILE.
#?   The position `after` and `before` need to be used with `-e REGEX` together.
#?
#?   [-e REGEX]
#?
#?   Must set with `-p <after | before>`.
#?   Only the first occurrence of REGEX is injected.
#?
#?   [-m MARK_BEGIN] and [-n MARK_END]
#?
#?   The CONTENT is wrapped within the marks.
#?   With begin and end mark, it is safe to repeat the injection.
#?
#?   [-x REGEX_MARK_BEGIN] and [-y REGEX_MARK_END]
#?
#?   Remove any content within the regex marks before the injection.
#?
#?   FILE
#?
#?   File to inject to.
#?   The /dev/stdin is not allowed.
#?
#? Bugs:
#?   1. Doesn't work with empty file.
#?   2. `/` can't be appearing in the regex of -e -x -y.
#?
#? @xsh /trap/err -e
#? @subshell
#?
function inject () {

    local OPTIND OPTARG opt

    local content file position regex mark_begin mark_end \
          regex_mark_begin regex_mark_end

    while getopts c:p:e:m:n:x:y: opt; do
        case $opt in
            c)
                content=$OPTARG
                ;;
            p)
                # begin, end, after, before
                position=$OPTARG
                ;;
            e)
                regex=$OPTARG
                ;;
            m)
                mark_begin=$OPTARG
                ;;
            n)
                mark_end=$OPTARG
                ;;
            x)
                regex_mark_begin=$OPTARG
                ;;
            y)
                regex_mark_end=$OPTARG
                ;;
            *)
                exit 255
                ;;
        esac
    done
    shift $((OPTIND - 1))
    file=${1:?}

    # backup file
    local bak_file
    bak_file="${file:?}-$(date '+%Y%m%d%H%M%S')"
    /bin/cp -a "${file:?}" "${bak_file:?}"

    # tmp file
    local tmp_file=/tmp/${file##*/}-inject-$$
    /bin/cp -a "${file:?}" "${tmp_file:?}"

    # set to clean tmp file
    xsh import /trap/return
    x-trap-return -F $FUNCNAME "rm -f ${tmp_file:?}"

    # add marks
    if [[ -n $mark_begin && -n $mark_end ]]; then
        content=$(printf '%s\n%s\n%s' "${mark_begin:?}" "${content:?}" "${mark_end:?}")
    fi

    # remove early injection if exists
    if [[ -n $regex_mark_begin && -n $regex_mark_end ]]; then
        xsh /util/sed-regex-inplace "/${regex_mark_begin:?}/,/${regex_mark_end:?}/d" \
            "${tmp_file:?}"
    fi

    # injecting into tmp file
    # TODO: doesn't work with empty file.
    case ${position:?} in
        begin)
            xsh /util/sed-inplace \
                "1 {
                h
                r /dev/stdin
                g
                N
                }" "${tmp_file:?}" <<< "${content:?}"
            ;;
        end)
            xsh /util/sed-inplace "$ r /dev/stdin" "${tmp_file:?}" <<< "${content:?}"
            ;;
        after)
            xsh /util/sed-regex-inplace "/${regex:?}/ r /dev/stdin" "${tmp_file:?}" \
                <<< "${content:?}"
            ;;
        before)
            xsh /util/sed-regex-inplace \
                "/${regex:?}/ {
                h
                r /dev/stdin
                g
                N
                }" "${tmp_file:?}" <<< "${content:?}"
            ;;
        *)
            exit 255
            ;;
    esac

    # apply injection
    /bin/cp -a "${tmp_file:?}" "${file:?}"
}
