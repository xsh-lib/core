#? Description:
#?   Apply operand on 2 sorted sets.
#?
#? Usage:
#?   @set SET OPERAND SET
#?
#? Options:
#?   SET
#?
#?   The set is a string contains sorted elements delimited by whitespace or newline.
#?
#?   OPERAND
#?
#?   &
#?   |
#?
#? Exmaple:
#?   @set '1 2 3 4' \& '3 4 5 6'
#?   # 3
#?   # 4
#?
function set () {

    function __pipe_space_to_newline () {
        awk '{for(i=1;i<=NF;i++) {print $i}}'
    }

    case $2 in
        \&)
            join <(echo "$1" | __pipe_space_to_newline) \
                 <(echo "$3" | __pipe_space_to_newline)
            ;;
        \|)
            join -a 1 -a 2 \
                 <(echo "$1" | __pipe_space_to_newline) \
                 <(echo "$3" | __pipe_space_to_newline)
            ;;
        *)
            return 255
            ;;
    esac

    unset -f __pipe_space_to_newline
}
