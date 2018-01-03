#!/bin/bash

[[ $DEBUG -gt 0 ]] && set -x

usage () {
    printf "Usage:\n"
    printf "\t$0 <OUTPUT_DELIMITER> <SET1> <SET2> [SET3] [...]\n"
    printf "Example:\n"
    printf "\t$0 '-' 'a b c' 'A B C'\n"
    printf "\t$0 '-' \"\$seq(1 10)\" \"\$(echo {A..Z})\"\n"
    exit 255
}

[[ $# -lt 3 ]] && usage

OUTPUT_DELIMITER=$1
shift

REPLACEMENT_SIGNATURE=
CORES=$(sysctl -n hw.ncpu)
COMMON_CMD="echo \$%s | xargs -n 1 | xargs -R -1 -I ${REPLACEMENT_SIGNATURE}%s"
# Must have -R -1 for OSX xargs, otherwise only 5 arguments will be replaced
# Use -P to parallel process
FIRST_LEVEL="$COMMON_CMD -P $CORES echo \$(<NESTED>)"
MIDDLE_LEVEL="$COMMON_CMD echo \$(<NESTED>)"
LAST_LEVEL="$COMMON_CMD echo <OUTPUT>"
CMD=''

i=1
while [[ $i -le $# ]]; do
    if [[ $i -eq 1 ]]; then
        # First set
        CMD=$(printf "$FIRST_LEVEL" $i $i) || exit $?
        output=$(printf "%s%s" "$REPLACEMENT_SIGNATURE" $i) || exit $?
    else
        if [[ $i -lt $# ]]; then
            # Middle set
            nested=$(printf "$MIDDLE_LEVEL" $i $i) || exit $?
        elif [[ $i -eq $# ]]; then
            # Last set
            nested=$(printf "$LAST_LEVEL" $i $i) || exit $?
        fi

        CMD=$(echo "$CMD" | sed "s/<NESTED>/$nested/") || exit $?
        output=$(printf '%s%s%s%s' "$output" "$REPLACEMENT_SIGNATURE" "$OUTPUT_DELIMITER" $i) || exit $?
    fi

    i=$((i+1)) || exit $?
done

CMD=$(echo "$CMD" | sed "s/<OUTPUT>/$output/") || exit $?
eval "$CMD"

exit $?
