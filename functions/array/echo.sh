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
#?   arr=(1 2 3)
#?   @echo arr
#?   1
#?   2
#?   3
#?
function echo () {
    eval printf \"%s\\n\" \"\${$1[@]}\"
}
