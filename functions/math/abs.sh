#? Usage:
#?   @abs NUMBER
#?
#? Output:
#?   The absolute value of NUMBER.
#?
function abs () { 
    printf "%s\n" "${1#-}"
}
