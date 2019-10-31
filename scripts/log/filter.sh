#!/usr/bin/env bash

set -eo pipefail

#? Description:
#?   Filter plain file by fields.
#?
#? Usage:
#?   @filter
#?     [-f N] [...]
#?     [-F N] [...]
#?     -s STRING
#?     FILE
#?
#? Options:
#?   [-f N] [...]
#?
#?   Return the matching lines on the Nth field in FILE.
#?   the STRING is matching as regex with case-sensitive.

#?   [-F N] [...]
#?
#?   Return the matching lines on the Nth field in FILE.
#?   the STRING is matching as literal string.
#?
#?   If both `-f` and `-F` are not set, then `-f0` is set as default to matching on
#?   entire line.
#?
#?   N: `0` meant entire line, `NF` meant last field, `2$3$1` meant joined field: 2+3+1.
#?
#?   If more than one `-f or -F` given, then taking the value of second Nth field of lines
#?   returned by the first match as STRING, to filter on the second Nth field with whole
#?   file, and repeat the step until all `-f` and `-F` are processed, to get final result.
#?
#?   -s STRING
#?
#?   String to match.
#?
#?   FILE
#?
#?   File path.
#?
function filter () {
    declare OPTIND OPTARG opt
    declare -a fields
    declare string

    while getopts f:F:s: opt; do
        case $opt in
            f)
                fields+=( -f "${OPTARG:?}" )
                ;;
            F)
                fields+=( -F "${OPTARG:?}" )
                ;;
            s)
                string=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND-1))
    declare file=$1

    if [[ -z $string || -z $file ]]; then
        xsh log "parameter null or not set."
        return 255
    fi

    if [[ ${#fields[@]} -eq 0 ]]; then
        fields=(-f 0)
    fi

    declare lines
    case ${fields[0]} in
        -f)
            lines=$(awk "\$${fields[1]} ~ /${string:?}/ {print}" "${file:?}")
            ;;
        -F)
            lines=$(awk "\$${fields[1]} == \"${string:?}\" {print}" "${file:?}")
            ;;
        *)
            xsh log error "${fields[0]}: unsupported option."
            return 255
            ;;
    esac

    unset fields[0] fields[1]

    if [[ -n $lines ]]; then
        if [[ ${#fields[@]} -gt 1 ]]; then
            declare -a strings
            # do not double quote this
            strings=($(awk "{ print \$${fields[3]} }" <<< "$lines" | sort -u))

            for string in "${strings[@]}"; do
                # recursive call
                filter "${fields[@]}" -s "${string:?}" "${file:?}"
            done
        else
            printf '%s\n' "$lines"
        fi
    else
        : # nothing to output
    fi
}

filter "$@"

exit
