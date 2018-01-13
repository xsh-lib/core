#? Usage:
#?   @lim m k1 k2
#?
#? Options:
#?   给定三个数字：m, k1, k2，求n，使计算式k1*(k2^n)的计算结果最大程度逼近m，但不得大于m。
#?
#? Output:
#?   The number n，n满足k1*(k2^n)最大程度逼近m，但不大于m。
#?
#? Example:
#?   @lim 28 3 2
#?   3
#? 
#? WolframAlpha:
#?   Solve[k1 k2^n == m, n]
#?   n=log(m/k1)/log(k2)
#?
function lim () {
    local m=$1 k1=$2 k2=$3

    awk -v m=${m} -v k1=${k1} -v k2=${k2} '{print int(log(m/k1)/log(k2))}'
}
