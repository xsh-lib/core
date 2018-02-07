#? Usage:
#?   @guid [LENGTH]
#?
#? Options:
#?   [LENGTH]  GUID length to generate.
#? Output:
#?   The GUID generated.
#?
#? Example:
#?   @guid 16
#?   # db4eb095a0a921f0cc1804cf7d01fec7
#?
function guid () {
    od  -vN "$1" -An -tx1 /dev/urandom | tr -d ' '
}
