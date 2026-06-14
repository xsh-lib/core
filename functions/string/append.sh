#? Usage:
#?   @append VAR VALUE ...
#?
#? Options:
#?   VAR    Variable name appending to.
#?   VALUE  Value to append, default separator is $IFS.
#?
#? Output:
#?   Nothing.
#?
#? Example:
#?   $ var=0; @append var {1..10}; echo "$var"
#?   0 1 2 3 4 5 6 7 8 9 10
#?
#?   $ var=0; IFS=- @append var {1..10}; echo "$var"
#?   0-1-2-3-4-5-6-7-8-9-10
#?
function append () {
    # `${!1}` is bash-only; `${*:2}` joins the values with the first
    # character of $IFS in both shells
    eval "${1:?}=\${${1}}\${IFS:0:1}\${*:2}"
}
