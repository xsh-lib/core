#? Edition:
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
#?   $ @dec2hex 255
#?   FF
#?
function dec2hex () {
    bc <<< "obase=16; ibase=10; $1"
}
