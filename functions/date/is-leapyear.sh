#? Description:
#?   Test whether the year of given date is leap year.
#?
#? Usage:
#?   @is-leapyear <TIMESTAMP>
#?
#? Return:
#?   0:    Yes
#?   !=0:  No
#?
#? Example:
#?   $ @is-leapyear 2012; echo $?
#?   0
#?
#?   $ @is-leapyear 2011; echo $?
#?   1
#?
function is-leapyear () {
    declare year
    year=$(xsh /date/year "${1:?}")

    if [[ $((year % 4)) -eq 0 && ( $((year % 100)) -ne 0 || $((year % 400)) -eq 0 ) ]] ; then
        return 0
    else
        return 1
    fi
}
