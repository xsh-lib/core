#? Description:
#?   Parse SQL expression and export the parsed into variables.
#?
#? Usage:
#?   @parse SQL
#?
#? Return:
#?   0: succeed
#?   255: error
#?
#? Export:
#?   Q_FIELDS
#?   Q_TABLE
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   @parse select f1,f2 from A
#?
function parse () {
    local clause

    Q_FIELDS=()
    Q_TABLE=

    while [[ $# -gt 0 ]]; do
        case $(x-string-lower "$1") in
            'select')
                clause='SELECT'
                ;;
            'from')
                clause="FROM"
                ;;
            *)
                case $clause in
                    'SELECT')
                        # parse the field list into array
                        IFS=',' read -r -a Q_FIELDS <<< "$1"
                        ;;
                    'FROM')
                        Q_TABLE=$1
                        ;;
                    *)
                        return 255
                        ;;
                esac
                ;;
        esac
        shift
    done

    if [[ -z ${Q_FIELDS[@]} || -z $Q_TABLE ]]; then
        return 255
    else
        export Q_FIELDS Q_TABLE
    fi
}
