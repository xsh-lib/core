#? Usage:
#?   @append ARRAY VALUE
#?
#? Options:
#?   ARRAY  Array name.
#?   VALUE  Value to append.
#?
#? Output:
#?   Nothing
#?
#? Example:
#?   arr=(1 2 3)
#?   @append arr 4
#?   echo ${arr[@]}
#?   1 2 3 4
#?
function append () {
    eval $1[$(xsh /array/inext "$1")]=\$2
}
