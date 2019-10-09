#? Description:
#?   Repeatly run command for N times.
#?
#? Usage:
#?   @rrun [-s] [-n TIMES] CMD [CMD_OPTIONS]
#?
#? Options:
#?   [-s]           Shell mode, the command will be executed with eval.
#?   [-n TIMES]     How many times the command will be run. Default is 1.
#?   CMD            Command will be run.
#?   [CMD_OPTIONS]  Command options, will be passed to command directly.
#?
#? Output:
#?   Depends on the CMD.
#?
#? Example:
#?   $ @rrun -n 3 echo 'Hello World'
#?   Hello World
#?   Hello World
#?   Hello World
#?
function rrun () {
    local OPTARG OPTIND opt
    local shell times i

    while getopts sn: opt; do
        case ${opt} in
            s)
                shell=eval
                ;;
            n)
                times=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    for ((i=0; i<${times:-1}; i++)); do
        $shell "$@"
    done
}
