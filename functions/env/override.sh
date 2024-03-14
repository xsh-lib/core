#? Description:
#?   Override environment variables with the input name=value expressions.
#?
#? Usage:
#?   @override [-a] [-m] [-s SEPARATOR] NAME=VALUE [...]
#?
#? Options:
#?   [-a]
#?
#?   If the NAME is Array, VALUE will be appended into array rather than directly set.
#?
#?   [-m]
#?
#?   Merge the elements of array by value, the later index of element would be used.
#?
#?   [-s SEPARATOR]
#?
#?   Separator in the value, if specified, only the part before the separator will be
#?   evaluated during the merge.
#?   This option is ignored unless `-m` is set.
#?
#?   NAME=VALUE [...]
#?
#?   NAME is the variable name that is overriding.
#?   VALUE is the new value to set.
#?   The first occurrence of equals sign `=` is the separator of NAME and VALUE.
#?
#? Example:
#?   $ a=(foo bar); x=24; y=25; z=0
#?   $ @override 'a[0]=Foo' 'a[1]=Bar' 'z=26'; echo ${a[@]},$x,$y,$z
#?   Foo Bar,24,25,26
#?
#?   $ a=(foo=foo bar=bar); x=24; y=25; z=0
#?   $ @override -a -m -s = 'a=foo=Foo' 'a=bar=Bar' 'z=26'; echo ${a[@]},$x,$y,$z
#?   foo=Foo bar=Bar,24,25,26
#?
function override () {
    declare OPTIND OPTARG __opt

    declare __append=0 __merge=0 __separator

    while getopts ams: __opt; do
        case $__opt in
            a)
                __append=1
                ;;
            m)
                __merge=1
                ;;
            s)
                __separator=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    declare __item __name __value
    declare -a __arrays

    for __item in "$@"; do
        __name=${__item%%=*}
        __value=${__item#*=}

        if  test $__append -eq 1 && xsh /array/is-array "$__name"; then
            # append array with value
            xsh /array/append "$__name" "$__value"
        else
            # set name=value
            xsh /string/copy __value "$__name"
        fi

        if xsh /array/is-array "$__name"; then
            # save array name
            __arrays+=( "$__name" )
        fi

    done

    if [[ $__merge -eq 1 ]]; then
        # merge elements of arrays
        for __name in "${__arrays[@]}"; do
            xsh /array/merge "$__name" "$__separator"
        done
    fi
}

