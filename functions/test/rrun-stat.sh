#? Description:
#?   Repeatly run command for N times and give performance statistics.
#?
#? Usage:
#?   @rrun-stat [-q] [-s] [-n TIMES] CMD [CMD_OPTIONS]
#?
#? Options:
#?   [-q]           Quiet mode, suppress the command's standard output.
#?   [-s]           Shell mode, the command will be executed with eval.
#?   [-n TIMES]     How many times the command will be run. Default is 1.
#?   CMD            Command will be run by 'time'.
#?   [CMD_OPTIONS]  Command options, will be passed to command directly.
#?
#? Output:
#?
#? Example:
#?   @rrun-stat -n 3 echo 'Hello World'
#?   Hello World
#?   Hello World
#?   Hello World
#?
#?   real   0m0.000s
#?   user   0m0.000s
#?   sys    0m0.000s
#?
function rrun-stat () {
    local OPTARG OPTIND opt
    local quiet

    while getopts qsn: opt; do
        case ${opt} in
            q)
                quiet=1
                unset $OPTIND
                ;;
            s|n)
                ;;
            *)
                return 255
                ;;
        esac
    done

    if [[ ${quiet} -eq 1 ]]; then
        time xsh /test/rrun "$@" >/dev/null
    else
        time xsh /test/rrun "$@"
    fi
}
