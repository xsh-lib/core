#? Version:
#?   Way of printf.
#?
#? Usage:
#?   @dec2hex DECIMAL
#?
#? Options:
#?   DECIMAL  Unsigned decimal.
#?            Min: 0
#?            Max: 18446744073709551615 (2^64-1)
#?
#? Output:
#?   Unsigned hexadecimal.
#?   Min: 0
#?   Max: 0xffffffffffffffff
#?
#? Example:
#?   @dec2hex 255
#?   0xff
#?
function dec2hex () {
    printf '%#x\n' "$1"
}
