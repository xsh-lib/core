#? Description:
#?   Let you be able to use `getopts` in this way: `./script -x foo bar -y baz`
#?   It will set an array OPTARG=(for bar) for the option `-x`.
#?   This works only within the `getopts` context.
#?
#? Usage:
#?   @extra "$@"; arr=( "${OPTARG[@]}" )
#?
#? Example:
#?   while getopts x:y: opt; do
#?     case $opt in
#?       x)
#?         @extra "$@"; x=( "${OPTARG[@]}" );;
#?       y)
#?         y=$OPTARG;;
#?     esac
#?   done
#?
function extra () {
    if [[ -z $OPTIND ]]; then
        xsh log error "not in the context of getopts."
        return 255
    fi

    declare i=1
    # if the next argument is not an option, then append it to array OPTARG
    while [[ ${OPTIND} -le $# && ${!OPTIND:0:1} != '-' ]]; do
        OPTARG[i]=${!OPTIND}
        let i++ OPTIND++
    done
}
