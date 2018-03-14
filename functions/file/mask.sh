#? Usage:
#?   @mask [-d DELIMITER] [-f LIST] [-c LIST] [-m MASK] [-x] FILE
#?
#? Option:
#?   [-d DELIMITER]  Use DELIMITER as the field delimiter character instead
#?                   of the tab character.
#?
#?   [-f LIST]       The list specifies fields.
#?
#?   [-c LIST]       The list specifies character positions.
#?
#?   [-m MASK]       Mask character.
#?
#?   [-x]            Use fixed length on masking string, 6 characters.
#?
#?   FILE            File name.
#?
#? Output:
#?   Masked content of file.
#?
#? Example:
#?   echo 'username password' | @mask -f2 -c1-4
#?   # username ****word
#?
function mask () {
    cat "$@" | xsh /file/pipe/mask
}
