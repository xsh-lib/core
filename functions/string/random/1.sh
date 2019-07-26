#? Usage:
#?   @random [LENGTH]
#?
#? Options:
#?   [LENGTH]  Number of characters to generate, default is 16.
#?             LENGTH should be an positive even number, if it's an odd number
#?             then will be rounded to an nearest smaller even number.
#?
#? Output:
#?   The random string generated.
#?
#? Example:
#?   @random 32
#?   # db4eb095a0a921f0cc1804cf7d01fec7
#?
function random () {
    od -vN "$((${1:-16} / 2))" -An -tx1 /dev/urandom | tr -d ' '
}
