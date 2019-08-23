#!/bin/bash -e -o pipefail

#? Description:
#?   Inject content into file.
#?
#? Usage:
#?   @inject
#?     -c CONTENT
#?     -f FILE
#?     -p <begin|end|after|before>
#?     [-e REGEX]
#?     [-m MARK_BEGIN]
#?     [-n MARK_END]
#?     [-x REGEX_MARK_BEGIN]
#?     [-y REGEX_MARK_END]
#?
#? Options:
#?   -c CONTENT
#?   Content to inject.
#?
#?   -f FILE
#?   File to inject to.
#?
#?   -p <begin|end|after|before>
#?   Where to inject in the FILE.
#?
#?   [-e REGEX]
#?   Use together with -p.
#?
#?   [-m MARK_BEGIN]
#?   Use together with -n.
#?   With begin and end mark, injection can be run repeatly and safety.
#?
#?   [-n MARK_END]
#?   Use together with -m.
#?   With begin and end mark, injection can be run repeatly and safety.
#?
#?   [-x REGEX_MARK_BEGIN]
#?   Use together with -y.
#?   With begin and end mark, injection can be run repeatly and safety.
#?
#?   [-y REGEX_MARK_END]
#?   Use together with -x.
#?   With begin and end mark, injection can be run repeatly and safety.
#?

# Clean on any exit
trap 'clean_exit $?' 0 SIGHUP SIGINT SIGTERM


clean_exit () {
    if [[ -n ${CLEANERS[@]} ]]; then
        eval "${CLEANERS[@]}"
    fi
    return $1
}

while getopts c:f:p:e:m:n:x:y: opt; do
    case $opt in
        c)
            content=$OPTARG
            ;;
        f)
            file=$OPTARG
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

# Backup
bak_file="${file:?}-$(date '+%Y%m%d%H%M%S')"
/bin/cp -a "${file:?}" "${bak_file:?}"

# Temporary file
tmp_file=/tmp/${0##*/}-${file##*/}-$$
tmp_inj_file=/tmp/${0##*/}-$$
/bin/cp -a "${file:?}" "${tmp_file:?}"

CLEANERS[${#CLEANERS[@]}]="rm -f ${tmp_file:?};"

if [[ -n $mark_begin && -n $mark_end ]]; then
    cat > "${tmp_inj_file:?}" << EOF
${mark_begin:?}
${content:?}
${mark_end:?}
EOF
else
    cat > "${tmp_inj_file:?}" << EOF
${content:?}
EOF
fi

CLEANERS[${#CLEANERS[@]}]="rm -f ${tmp_inj_file:?};"

# Remove early injection if exists
if [[ -n $regex_mark_begin && -n $regex_mark_end ]]; then
    xsh /util/sed-regex-inplace "/${regex_mark_begin:?}/,/${regex_mark_end:?}/d" "${tmp_file:?}"
fi

# Injecting
# TODO: sed command 'r' won't work with an empty file.

case ${position:?} in
    begin)
        xsh /util/sed-inplace \
            "1 {
            h
            r ${tmp_inj_file:?}
            g
            N
            }" "${tmp_file:?}"
        ;;
    end)
        xsh /util/sed-inplace "$ r ${tmp_inj_file:?}" "${tmp_file:?}"
        ;;
    after)
        xsh /util/sed-regx-inplace "/${regex:?}/ r ${tmp_inj_file:?}" "${tmp_file:?}"
        ;;
    before)
        xsh /util/sed-regx-inplace \
            "/${regex:?}/ {
            h
            r ${tmp_inj_file:?}
            g
            N
            }" "${tmp_file:?}"
        ;;
    *)
        exit 255
        ;;
esac

/bin/cp -a "${tmp_file:?}" "${file:?}"

exit
