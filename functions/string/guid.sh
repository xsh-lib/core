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
#?   8B5C9A13836CFFE6EAD2F2C9475511D4
#?
function guid () {
    # the number in below range have 16 char in HEX
    #   2000000000000000000 - 18000000000000000000
    #   1bc16d674ec80000 - f9ccd8a1c5080000
    # [2-17][integer in 18 strings of bit]
    printf %X $((RANDOM % 9 + RANDOM % 8 + 2))$(echo $RANDOM$RANDOM$RANDOM$RANDOM$RANDOM | cut -c1-18)
}

od  -vN "16" -An -tx1 /dev/urandom | tr -d " \n"; echo;
