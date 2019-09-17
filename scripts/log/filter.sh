#!/bin/bash

set -eo pipefail

if [[ $DEBUG -gt 0 ]]; then
    set -x
else
    set +x
fi

match_field_by_regexp () {
    local field=${1:?}
    local regexp=${2:?}
    shift 2

    awk -v field=${field:?} \
        -v regexp=${regexp:?} \
        '{if (match($field, ".*" regexp ".*") > 0) print}' \
        "$@"
}

match_field_by_string () {
    local field=${1:?}
    local string=${2:?}
    shift 2

    awk -v field=${field:?} \
        -v string=${string:?} \
        '{if ($field == string) print}' \
        "$@"
}

cut_with_unique_sorted() {
    cut "$@" | sort -u
}

match () {

    usage () {
        printf "${0##*/}\n"
        printf "\t[-n | -N <N>] ...\n"
        printf "\t-s STRING\n"
        printf "\tFILE\n"

        printf "OPTIONS\n"
        printf "\t[-n | -N <N>] ...\n\n"
        printf "\tReturn lines that matches the <STRING> on <N>th field in FILE.\n"
        printf "\tWith -n, matching <STRING> as Regexp.\n"
        printf "\tWith -N, matching <STRING> as exact String.\n\n"

        printf "\t[-n | -N <N>] ...\n\n"
        printf "\tIf multi -n/-N given, then return lines that matches the later <N>th field\n"
        printf "\tof the lines returned by former <N>th field in FILE. And call recursively\n"
        printf "\tto get result.\n\n"

        printf "\t-s STRING\n\n"
        printf "\tReturn lines that matches the STRING on whole line in FILE.\n\n"

        printf "\tFILE\n\n"
        printf "\tFile path.\n\n"

        printf "\t-h\n\n"
        printf "\tThis help.\n\n"
        exit 255
    }

    local fields=()
    local string

    local opt
    local OPTIND
    while getopts n:N:s:h opt; do
        case $opt in
            n)
                fields+=( -n "$OPTARG" )
                ;;
            N)
                fields+=( -N "$OPTARG" )
                ;;
            s)
                string=$OPTARG
                ;;
            h|*)
                usage >&2
                ;;
        esac
    done
    shift $((OPTIND-1))
    local file=$1

    if [[ -z $string || -z $file ]]; then
        usage >&2
    fi

    local field_opt field lines
    if [[ ${#fields[@]} -ge 2 ]]; then
        local field_opt=${fields[0]}
        local field=${fields[1]}
        unset fields[0]
        unset fields[1]

        if [[ $field_opt == '-n' ]]; then
            lines="$(match_field_by_regexp "${field:?}" "${string:?}" "${file:?}")"
        elif [[ $field_opt == '-N' ]]; then
            lines="$(match_field_by_string "${field:?}" "${string:?}" "${file:?}")"
        else
            :
        fi
    else
        lines="$(egrep "${string:?}" "${file:?}")"
    fi

    if [[ -n $lines ]]; then
        if [[ ${#fields[@]} -ge 2 ]]; then
            local strings string
            strings=( $(echo "$lines" | cut_with_unique_sorted -d ' ' -f "${fields[3]}") )
            for string in "${strings[@]}"; do
                # Recursively call
                match "${fields[@]}" -s "${string:?}" "${file:?}"
            done
        else
            echo "$lines"
        fi
    else
        : # Nothing to output
    fi
}

match "$@"

exit
