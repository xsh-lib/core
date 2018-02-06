#? Usage:
#?   @append ARRAY VALUE
#?
#? Options:
#?   ARRAY  Array name.
#?   VALUE  Value to append.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   arr=([3]="III" [4]="IV"); @append arr "V"; declare -p arr
#?   # declare -a arr='([3]="III" [4]="IV" [5]="V")'
#?
function append () {
    read "$1[$(xsh /array/inext "$1")]" <<< "$2"
}
