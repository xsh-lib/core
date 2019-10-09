#? Usage:
#?   @echo ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ arr=([3]="III" [4]="IV"); @echo arr
#?   III
#?   IV
#?
function echo () {
    # try to declare nothing, new variable may override input variable.
    set -- "$1[@]"
    printf "%s\n" "${!1}"
}
