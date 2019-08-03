#? Description:
#?   An implementation of Shunting Yard Algorithm in Bash.
#?   Convert an expression in Infix Notation to an expression in RPN(Reverse Polish Notation).
#?
#?   Implement: https://en.wikipedia.org/wiki/Shunting-yard_algorithm
#?   RPN: https://en.wikipedia.org/wiki/Reverse_Polish_notation
#?
#? Usage:
#?   @infix2rpn [-c COMPARATOR] [-d DELIMITER] EXPR
#?
#? Options:
#?   EXPR
#?
#?   The Infix Expression to convert.
#?   The operands in the EXPR can contain [0-9] and [[:blank:]].
#?
#?   [-c COMPARATOR]
#?
#?   The operator comparator callable, used to calculate the priority of 2 operators.
#?   Give 2 operators, the function should output:
#?     = 0: The two have equal priority.
#?     > 0: The former is higher than the later.
#?     < 0: The former is lower than the later.
#?
#?   Give no any parameter, the function should output a list of operators this
#?   comparator supported. It would also be used to check the vailability of the
#?   comparator.
#?
#?   The default comparator is 'xsh /int/op-comparator', support following operators:
#?     + - * / % ^
#?
#?   [-c DELIMITER]
#?
#?   The delimiter used to separate the symbols of output expression.
#?   Default delimiter is a whitespace.
#?   Set a delimiter other than whitespace, such as '\n', if your operands contains
#?   whitespaces itself.
#?
#? Example:
#?   @infix2rpn '2*3+(4-5)'
#?   # 2 3 * 4 5 - +
#?
#?   @infix2rpn -c 'xsh /int/set/op-comparator' -d '\n' '2 3&(3 4|4 5)'
#?   # 2 3
#?   # 3 4
#?   # 4 5
#?   # |
#?   # &
#?
#? A sample implementation for the operator comparator function.
#?
#?   #########
#?   function op-comparator-for-set () {
#?
#?     local OPERATORS=(
#?         [0]='|'
#?         [1]='&'
#?     )
#?
#?     function priority () {
#?       case $1 in
#?         '|')
#?           echo 1
#?           ;;
#?         '&')
#?           echo 2
#?           ;;
#?       esac
#?     }
#?
#?     if [[ -n $1 && -n $2 ]]; then
#?         local p1=$(priority "$1")
#?         local p2=$(priority "$2")
#?         echo "$((p1 - p2))"
#?     else
#?         echo "${OPERATORS[@]}"
#?     fi
#?
#?     unset priority
#?   }
#?   #########
#?
function infix2rpn () {
    declare -a OUTPUT
    declare -a STACK

    # Set default operator comparator
    xsh import /int/op-comparator
    local COMPARATOR=x-int-op-comparator

    # Set default output delimiter
    local DELIMITER=' '

    local OPTIND OPTARG opt
    while getopts c:d: opt; do
        case $opt in
            c)
                COMPARATOR=$OPTARG
                ;;
            d)
                DELIMITER=$OPTARG
                ;;
            *)
                return 255
                ;;
        esac
    done
    shift $((OPTIND - 1))

    function __process_operand () {
        if [[ -n $operand ]]; then
            OUTPUT[${#OUTPUT[@]}]="${operand%"${operand##*[![:space:]]}"}"
        fi
        unset operand
    }

    function __process_operator () {
        if [[ -n $operator ]]; then
            while [[ ${#STACK[@]} -gt 0 && ${STACK[@]:(-1)} != '(' ]]; do
                priority=$($COMPARATOR "$operator" "${STACK[@]:(-1)}")
                if [[ -z $priority ]]; then
                    printf "Wrong operator in the expression or specified wrong comparator\n" >&2
                    return 255
                elif [[ $priority -gt 0 ]]; then
                    break
                else
                    OUTPUT[${#OUTPUT[@]}]="${STACK[@]:(-1)}"
                    unset STACK[$((${#STACK[@]} - 1))]
                fi
            done
            STACK[${#STACK[@]}]=$operator
        fi
        unset operator
    }

    # Check op-comparator vailability
    if ! $COMPARATOR >/dev/null 2>&1; then
        printf "$FUNCNAME: ERROR: Not found the operator comaparator: %s.\n" "$COMPARATOR" >&2
        return 255
    fi

    # Convert Infix to RPN

    local operand operator priority
    local char
    while IFS= read -r -n1 char; do
        case "$char" in
            # WHITESPACE or TAB
            [[:blank:]])
                if [[ -n $operand ]]; then
                    # Blanks within OPERAND is meaningful
                    operand="$operand$char"
                fi
                ;;
            '(')
                __process_operator || return $?

                STACK[${#STACK[@]}]=$char
                ;;
            ')')
                __process_operand || return $?

                while [[ ${STACK[@]:(-1)} != '(' ]]; do
                    OUTPUT[${#OUTPUT[@]}]="${STACK[@]:(-1)}"
                    unset STACK[$((${#STACK[@]} - 1))]
                done

                if [[ ${STACK[@]:(-1)} == '(' ]]; then
                    unset STACK[$((${#STACK[@]} - 1))]
                else
                    printf "$FUNCNAME: ERROR: Wrong expression found! Found a right parenthesis ')' without a paired left parentthesis '('.\n" >&2
                    return 255
                fi
                ;;
            # OPERANDS
            [0-9])
                __process_operator || return $?

                operand="$operand$char"
                ;;
            # OPERATORS
            *)
                __process_operand || return $?

                operator="$operator$char"
                ;;
        esac
    done <<< "${*//$'\n'/ }"  # Replace newline as whitespace

    while [[ ${#STACK[@]} -gt 0 ]]; do
        OUTPUT[${#OUTPUT[@]}]="${STACK[@]:(-1)}"
        unset STACK[$((${#STACK[@]} - 1))]
    done

    unset -f __process_operand __process_operator
    printf "%s$DELIMITER" "${OUTPUT[@]}"
}
