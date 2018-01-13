#? Usage:
#?   @runx [-s] N CMD [CMD_OPTIONS]
#?
#? Options:
#?   [-s]           Shell mode, the command will be executed with eval.
#?   N              How many times the command will be run. Default is 1.
#?   CMD            Command will be run.
#?   [CMD_OPTIONS]  Command options, will be passed to command directly.
#?
#? Output:
#?
#? Example:
#?   @runx 3 echo 'Hello World'
#?   Hello World
#?   Hello World
#?   Hello World
#?
function runx () {
    local OPTARG OPTIND opt
    local shell i
    
    while getopts s opt; do
        case ${opt} in
            s)
                shell=eval
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    for ((i=0; i<$1; i++)); do
        $shell "${@:2}"
    done
}
