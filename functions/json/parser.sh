#? Desription:
#?   Parse JSON string with Python.
#?
#? Usage:
#?   @parser <METHOD> <JSON> <EXPRESSION>
#?
#? Options:
#?   <METHOD>      Allowed methods: get, eval.
#?
#?   <JSON>        JSON string to parse.
#?
#?   <EXPRESSION>  Expression for the method.
#?
#?                 The expression for method `get` has syntax:
#?                 `<key | method | [[x][:][y]]>[.expression]`
#?
#?                 key          Key defined in the JSON.
#?
#?                 method       Python builtin method for the object.
#?                              Syntax: `<method_name>([args])`
#?                              E.g.: `keys()`.
#?
#?                 [[x][:][y]]  List selector, used to filter list.
#?                              Syntax: `* | [0-N]`.
#?                              `[*]`   get all elements.
#?                              `[x]`   get the xth element.
#?                              `[x:y]` get the elements from x to y.
#?                              `[x:]`  get the elements from x to end.
#?                              `[:y]`  get the elements from begin to y.
#?
#?                 .             The dot `.` is the delimiter of expressions.
#?
#?                 The expression for method `eval` is a Python expression.
#?                 Special token `{JSON}` is used to reference to the JSON object in the
#?                 eval expression.
#?
#? Output:
#?   The parsed result in string.
#?
#? Example:
#?   $ @parser get '{"foo": ["bar", "baz"]}' 'foo.[0].upper()'
#?   BAR
#?
#?   $ @parser eval '{"foo": ["bar", "baz"]}' '[item.upper() for item in {JSON}["foo"]]'
#?   ["BAR", BAZ"]
#?
function parser () {
    declare BASE_DIR=${XSH_HOME}/lib/x/functions/json  # TODO: use varaible instead
    python "$BASE_DIR"/parser.py "$@"
}
