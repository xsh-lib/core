#? Usage:
#?   @echo ARRAY
#?
#? Options:
#?   ARRAY  Array name.
#?
#? Examples:
#?   arr=(1 2 3)
#?   @echo arr
#?   1
#?   2
#?   3
#?
function echo () {
    local i
    
    for i in $(eval echo \${!$1[@]}); do
        eval echo \"\${$1[$i]}\"
    done
}
