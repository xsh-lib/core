#? Version:
#?   Way of printf.
#?
#? Usage:
#?   @dec2hex DECIMAL
#?
#? Options:
#?   DECIMAL  Signed decimal.
#?            Min: -18446744073709551615 (-2^64-1)
#?            Max: 18446744073709551615 (2^64-1)
#?
#? Output:
#?   Signed hexadecimal.
#?   Min: -FFFFFFFFFFFFFFFF
#?   Max: FFFFFFFFFFFFFFFF
#?
#? Example:
#?   @dec2hex 255
#?   FF
#?
function dec2hex () {
    if [[ $1 -gt 0 ]]; then
        printf '%X\n' "$1"
    else
        printf '%s%X\n' '-' "${1#-}"
    fi
}
