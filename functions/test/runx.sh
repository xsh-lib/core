#? Usage:
#?   @runx N CMD [CMD_OPTIONS]
#?
#? Options:
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
    local i

    for i in {1..$1}; do
        "${@:2}"
    done
}
