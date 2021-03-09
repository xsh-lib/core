#!/bin/bash

set -e -o pipefail

xsh log info 'xsh list /'
xsh list /

xsh log info "/array/first"
[[ $(arr=([3]="III" [4]="IV"); xsh /array/first arr) == III ]]

xsh log info "/file/mask"
[[ $(xsh /file/mask -f2 -c1-4 <<< "username password") == "username ****word" ]]

xsh log info "/date/adjust"
[[ $(xsh /date/adjust +30M +30S "2008-10-10 00:00:00") == "2008-10-10 00:30:30" ]]

xsh log info "/date/convert"
[[ $(TZ=UTC xsh /date/convert "2008-10-10 00:30:30" "+%a %b  %d %T %Z %Y") == "Fri Oct  10 00:30:30 UTC 2008" ]]

xsh log info "/math/dec2hex"
[[ $(xsh /math/dec2hex 255) == FF ]]

xsh log info "/math/infix2rpn"
[[ $(xsh /math/infix2rpn "2*3+(4-5)") == "2 3 * 4 5 - + " ]]

xsh log info "/int/op-comparator"
[[ $(xsh /int/op-comparator "*" +) == 1 ]]

xsh log info "/int/set/rpncalc"
[[ $(xsh /int/set/rpncalc "1 2 3" "3 4 5" \&) == 3 ]]

xsh log info "/json/parser"
[[ $(xsh /json/parser get '{"foo": ["bar", "baz"]}' "foo.[0].upper()") == BAR ]]

xsh log info "/json/parser"
[[ $(xsh /string/repeat Foo 3) == FooFooFoo ]]

xsh log info "/uri/parser"
[[ $(xsh /uri/parser -s https://github.com) == https ]]

xsh log info "/sql/parser"
[[ $(xsh /sql/parser select f1,f2 from A where f1 = x; set | grep ^Q_WHERE) == 'Q_WHERE=([0]="f1" [1]="=" [2]="x")' ]]

# TODO: Use the utilities's document (the section `Example`) to generate the
#       test cases.

exit
