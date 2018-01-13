#? Usage:
#?   @timex [-q] N CMD [CMD_OPTIONS]
#?
#? Options:
#?   [-q]           Quiet mode, suppress the command's standard output.
#?   N              How many times the command will be run. Default is 1.
#?   CMD            Command will be run by 'time'.
#?   [CMD_OPTIONS]  Command options, will be passed to command directly.
#?
#? Output:
#?
#? Example:
#?   @timex 3 echo 'Hello World'
#?   Hello World
#?   Hello World
#?   Hello World
#?
#?   real	0m0.000s
#?   user	0m0.000s
#?   sys	0m0.000s
#?
function timex () {
    local OPTARG OPTIND opt
    local quiet
    
    while getopts q opt; do
        case ${opt} in
            q)
                quiet=1
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ ${quiet} -eq 1 ]]; then
        time xsh /test/runx "$@" >/dev/null
    else
        time xsh /test/runx "$@"
    fi
}
