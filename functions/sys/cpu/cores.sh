#? Description:
#?   Get the number of cores of CPU.
#?
#? Usage:
#?   @cores
#?
#? Example:
#?   $ @cores
#?   4
#?
function cores () {
    sysctl -n hw.ncpu
}
