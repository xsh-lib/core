#? Description:
#?   Get the end day of month of a given date.
#?
#? Usage:
#?   @eomonth <TIMESTAMP>
#?
#? Example:
#?   @eomonth 2012-10
#?   31
#?
#?   @eomonth 2012-02-01
#?   29
#?
function eomonth () {
    case $(expr $(xsh /date/month "${1:?}")) in
        1|3|5|7|8|10|12)
            echo 31
            ;;
        4|6|9|11)
            echo 30
            ;;
        2)
            xsh /date/eofeb "$1"
            ;;
        *)
            return 255
            ;;
    esac
}
