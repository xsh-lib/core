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
    eval "printf '%s\n' \"\${${1:?}[@]}\""
}
