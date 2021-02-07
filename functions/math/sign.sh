#? Description:
#?   Find the value of `Y` to the given number `X` for the equation `Y=f(X)={Y=X^0 if X!=0, Y=0 if X=0}`.
#?
#? Usage:
#?   @sign <NUMBER>
#?
#? Output:
#?   0:   IF X=0
#?   1:   If X>0 or X=NaN (Not a Number)
#?  -1:   If X<0
#?
function sign () {
    awk -v x="${1:?}" 'BEGIN {if (x == 0) print x; else print x^0}'
}
