#? Version:
#?   Way of bc.
#?
#? Usage:
#?   @hex2dec HEX
#?
#? Options:
#?   HEX  Signed hexadecimal.
#?
#? Output:
#?   Signed decimal.
#?
#? Example:
#?   @hex2dec FF
#?   # 255
#?
function hex2dec () {
    local hex

    hex=$(xsh /string/upper "$1")
    case ${hex:0:1} in
        -)
            case ${hex:1:2} in
                0x|0X)
                    bc <<<$(echo "obase=10; ibase=16; -${hex:3}")
                    ;;
                *)
                    bc <<<$(echo "obase=10; ibase=16; ${hex}")
                    ;;
            esac
            ;;
        *)
            case ${hex:0:2} in
                0x|0X)
                    bc <<<$(echo "obase=10; ibase=16; ${hex:2}")
                    ;;
                *)
                    bc <<<$(echo "obase=10; ibase=16; ${hex}")
                    ;;
            esac
            ;;
    esac
}
