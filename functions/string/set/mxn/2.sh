#? Description:
#?   Generate Cartesian Product by the lines of files.
#?
#? Edition:
#?   Based on 'join' utility.
#?
#? Usage:
#?   @mxn [-t CHAR] <FILE1> <FILE2> [...]
#?
#? Options:
#?   FILE1 FILE2 [...]   The files to be joined.
#?
#?   [-t CHAR]           Use character char as a field delimiter for both input
#?                       and output. Every occurrence of char in a line is
#?                       significant.
#?
#?                       The default field separators are tab and space
#?                       characters. In this case, multiple tabs and spaces
#?                       count as a single field separator, and leading tabs
#?                       and spaces are ignored.
#?
#?                       The default output field separator is a single space
#?                       character.
#?
#? Example:
#?   @mxn -t '-' <(printf "%s\n" Hello World) <(printf "%s\n" Foo Bar)
#?   # Hello-Foo
#?   # Hello-Bar
#?   # World-Foo
#?   # World-Bar
#?
#? Alternation:
#?   1. Bash's Brace Expansion
#?
#?      echo {a..c}-{1..3}
#?
#?      This method:
#?      * Is very handy for the character set like [a-zA-Z0-9].
#?      * Can not use variables.
#?
#?   2. Utility: xargs
#?
#?      See: xsh help /string/set/mxn/1
#?
function mxn () {

    #? Usage:
    #?   __mxn [-t CHAR] [-l level] <FILE1> <FILE2> [...]
    #?
    #? Options:
    #?   [-t CHAR]   Use character char as a field delimiter for both input
    #?               and output.  Every occurrence of char in a line is
    #?               significant.
    #?   [-l LEVEL]  Used internally during recursive call. Default is 1.
    #?
    #? Example:
    #?   __mxn -t '-' <(printf "%s\n" Hello World) <(printf "%s\n" Foo Bar)
    #?   # Hello-Foo
    #?   # Hello-Bar
    #?   # World-Foo
    #?   # World-Bar
    #?
    function __mxn () {
        local OPTIND OPTARG opt

        # Set default
        local level=1

        # Options passing through to join
        declare -a options

        while getopts t:l: opt; do
            case $opt in
                t)
                    options+=( "-$opt" )
                    options+=( "$OPTARG" )
                    ;;
                l)
                    level=$OPTARG
                    ;;
                *)
                    return 255
                    ;;
            esac
        done
        shift $((OPTIND - 1))

        declare -a output_options
        local i=2
        while [[ $i -lt $# ]]; do
            output_options+=( '-o' )
            output_options+=( "2.$i" )
            i=$((i + 1))
        done

        local file1=$1 file2
        if [[ $# -gt 2 ]]; then
            # 3 or more FILEs left
            file2=<(__mxn "${options[@]}" -l "$((level + 1))" "${@:2}")
        else
            # 2 FILEs left
            file2=$2
        fi

        join -j -1 -o 1.1,2.1 "${output_options[@]}" "${options[@]}" \
             "$file1" "$file2"
    }

    __mxn "$@"
    unset -f __mxn
}
