#? Version:
#?   Way of printf.
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
#?   @hex2dec 0xff
#?   255
#?
function hex2dec () {
    bc <<<$(echo "obase=10; ibase=16; $1")
}
