#? Version:
#?   Way of bc.
#?
#? Usage:
#?   @dec2hex DECIMAL
#?
#? Options:
#?   DECIMAL  Signed decimal.
#?
#? Output:
#?   Signed hexadecimal.
#?
#? Example:
#?   @dec2hex 255
#?   0xff
#?
function dec2hex () {
    bc <<<$(echo "obase=16; ibase=10; $1")
}
