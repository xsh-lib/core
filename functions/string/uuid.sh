#? Description:
#?   Generate a pseudo UUID
#?
#?   Author: markusfisch
#?   Gist URL: https://gist.github.com/markusfisch/6110640
#?   UUID: https://en.wikipedia.org/wiki/Universally_unique_identifier
#?
#? Usage:
#?   @uuid
#?
#? Output:
#?   The UUID generated.
#?
#? Example:
#?   $ @uuid
#?   35b6aef6-af88-11e9-82fc-a3557caf0724
#?
function uuid () {
    declare N B C='89ab'
    for (( N=0; N < 16; ++N ))
    do
        B=$(( $RANDOM%256 ))
        case $N in
            6)
                printf '4%x' $(( B%16 ))
                ;;
            8)
                printf '%c%x' ${C:$RANDOM%${#C}:1} $(( B%16 ))
                ;;
            3 | 5 | 7 | 9)
                printf '%02x-' $B
                ;;
            *)
                printf '%02x' $B
                ;;
        esac
    done
    echo
}
