#? Usage:
#?   @abs NUMBER
#?
#? Output:
#?   The absolute value of NUMBER.
#?
function abs () { 
    echo "${1#-}"
}
