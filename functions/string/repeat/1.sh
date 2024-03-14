#? Edition:
#?   Way of recursion with awk.
#?
#? Usage:
#?   @repeat STRING [N]
#?
#? Options:
#?   STRING  String to repeat.
#?   [N]     Repeat N times, default is 1, means no repeat.
#?
#? Output:
#?   Concatenation of N STRINGs.
#?
#? Example:
#?   $ @repeat Foo 3
#?   FooFooFoo
#?
function repeat () {
    declare str=$1 times=${2:-1}

    if [[ -z ${str} ]]; then
        return
    fi

    awk -v str="${str}" \
        -v times="${times}" '
        function lim(m, k1, k2) {
            return int(log(m/k1)/log(k2))
        }
        function repeat(str, times,
                        # declare variables
                        lstr, lresult, limit, result, i, remain_times) {
            lstr=length(str)
            lresult=lstr*times
            limit=lim(lresult, lstr, 2)

            result=str
            for (i=0; i<limit; i++) {
                result=result result
            }

            remain_times=(lresult-lstr*(2^limit))/lstr

            if (remain_times > 0) {
                result=result repeat(str, remain_times)
            }

            return result
        }
        BEGIN { print repeat(str, times) }'
}
