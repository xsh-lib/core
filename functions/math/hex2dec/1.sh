#? Version:
#?   Way of printf.
#?
#? Usage:
#?   @hex2dec HEX
#?
#? Options:
#?   HEX  Signed hexadecimal.
#?        Min: -0x8000000000000000
#?        Max: 0x7fffffffffffffff
#?
#? Output:
#?   Signed decimal.
#?   Min: -9223372036854775808 (-2^63)
#?   Max: 9223372036854775807 (2^63-1)
#?
#? Example:
#?   @hex2dec 0xff
#?   255
#?
function hex2dec () {
    printf '%d\n' "$1"
}
