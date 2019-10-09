#? Edition:
#?   Way of printf.
#?
#? Usage:
#?   @hex2dec HEX
#?
#? Options:
#?   HEX  Signed hexadecimal.
#?        Min: -8000000000000000
#?        Max: 7fffffffffffffff
#?
#? Output:
#?   Signed decimal.
#?   Min: -9223372036854775808 (-2^63)
#?   Max: 9223372036854775807 (2^63-1)
#?
#? Example:
#?   $ @hex2dec FF
#?   255
#?
function hex2dec () {
    case ${1:0:1} in
        -)
            case ${1:1:2} in
                0x|0X)
                    printf '%d\n' "$1"
                    ;;
                *)
                    printf '%d\n' "-0X${1:1}"
                    ;;
            esac
            ;;
        *)
            case ${1:0:2} in
                0x|0X)
                    printf '%d\n' "$1"
                    ;;
                *)
                    printf '%d\n' "0X$1"
                    ;;
            esac
            ;;
    esac
}
