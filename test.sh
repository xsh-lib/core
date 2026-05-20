#!/bin/bash

set -e -o pipefail

xsh log info 'xsh list /'
xsh list /

xsh log info "/array/first"
# shellcheck disable=SC2034
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

# ---------- dotfile ----------
# Tests use a temporary repo with a .dotfilemap to avoid depending on any
# real dotfile repository.

xsh log info "/dotfile/resolve, /dotfile/list, /dotfile/status, /dotfile/load, /dotfile/install, /dotfile/diff"

__dotfile_test_dir=$(mktemp -d "${TMPDIR:-/tmp}/xsh-dotfile-test.XXXXXXXX")
trap 'rm -rf "$__dotfile_test_dir"' EXIT

# build a fake dotfile repo and a fake HOME
__df_repo=$__dotfile_test_dir/repo
__df_home=$__dotfile_test_dir/home
mkdir -p "$__df_repo/bash" "$__df_repo/conf" "$__df_home/.config"

# create repo files
echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "repo-conf-content"    > "$__df_repo/conf/app.conf"

# create home files (slightly different to test diff/status)
echo "home-profile-content" > "$__df_home/.profile"
echo "repo-conf-content"    > "$__df_home/.config/app.conf"   # identical

# write .dotfilemap
cat > "$__df_repo/.dotfilemap" <<'MAP'
bash/profile:HOME_PLACEHOLDER/.profile:source
conf/app.conf:HOME_PLACEHOLDER/.config/app.conf
MAP
# replace placeholder with the actual temp home path
sed -i'' -e "s|HOME_PLACEHOLDER|$__df_home|g" "$__df_repo/.dotfilemap"

# point the tool at the fake repo; override HOME so tilde display works
export XSH_DOTFILE_REPO=$__df_repo
__saved_home=$HOME
export HOME=$__df_home

# --- resolve ---
xsh log info "/dotfile/resolve (all)"
__resolve_out=$(xsh /dotfile/resolve)
[[ $(echo "$__resolve_out" | wc -l | tr -d ' ') == 2 ]]

xsh log info "/dotfile/resolve (filter)"
__resolve_out=$(xsh /dotfile/resolve profile)
[[ $(echo "$__resolve_out" | wc -l | tr -d ' ') == 1 ]]
[[ $__resolve_out == *"bash/profile"* ]]

xsh log info "/dotfile/resolve (no match)"
! xsh /dotfile/resolve zzz_no_match 2>/dev/null

# --- list ---
xsh log info "/dotfile/list"
__list_out=$(xsh /dotfile/list)
[[ $__list_out == *"bash/profile"* ]]
[[ $__list_out == *"[source]"* ]]
[[ $__list_out == *"conf/app.conf"* ]]

# --- status ---
xsh log info "/dotfile/status (mixed)"
__status_out=$(xsh /dotfile/status)
[[ $__status_out == *"[M] bash/profile"* ]]         # files differ
[[ $__status_out == *"[=] conf/app.conf"* ]]         # files identical

# --- diff ---
xsh log info "/dotfile/diff (modified file)"
__diff_out=$(xsh /dotfile/diff profile)
[[ $__diff_out == *"=== bash/profile ==="* ]]
[[ $__diff_out == *"repo-profile-content"* ]]

xsh log info "/dotfile/diff (identical file)"
__diff_out=$(xsh /dotfile/diff app.conf)
[[ $__diff_out == *"=== conf/app.conf ==="* ]]
# diff produces no output for identical files — just the header
[[ $(echo "$__diff_out" | wc -l | tr -d ' ') == 1 ]]

# --- load (HOME -> repo) ---
xsh log info "/dotfile/load (single)"
__load_out=$(xsh /dotfile/load profile)
[[ $__load_out == *"LOAD"* ]]
# repo file should now match home file
[[ $(cat "$__df_repo/bash/profile") == "home-profile-content" ]]

# restore repo file for further tests
echo "repo-profile-content" > "$__df_repo/bash/profile"

xsh log info "/dotfile/load -a"
__load_out=$(xsh /dotfile/load -a)
[[ $(echo "$__load_out" | grep -c "LOAD") == 2 ]]

# --- install (repo -> HOME) ---
# restore repo file, make home different
echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "old-home-content"     > "$__df_home/.profile"

xsh log info "/dotfile/install (single)"
__install_out=$(xsh /dotfile/install profile)
[[ $__install_out == *"INSTALL"* ]]
[[ $__install_out == *"source"* ]]  # post-install hint
[[ $(cat "$__df_home/.profile") == "repo-profile-content" ]]

xsh log info "/dotfile/install -a"
echo "changed" > "$__df_repo/conf/app.conf"
__install_out=$(xsh /dotfile/install -a)
[[ $(echo "$__install_out" | grep -c "INSTALL") == 2 ]]
[[ $(cat "$__df_home/.config/app.conf") == "changed" ]]

# --- status after sync ---
echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "repo-profile-content" > "$__df_home/.profile"
echo "changed"              > "$__df_repo/conf/app.conf"

xsh log info "/dotfile/status (all in sync)"
__status_out=$(xsh /dotfile/status)
[[ $(echo "$__status_out" | grep -c "\[=\]") == 2 ]]

# --- status with missing file ---
rm "$__df_home/.profile"
xsh log info "/dotfile/status (missing home file)"
__status_out=$(xsh /dotfile/status profile)
[[ $__status_out == *"[!]"* ]]
[[ $__status_out == *"home file missing"* ]]

# --- error cases ---
xsh log info "/dotfile/load (no args = error)"
! xsh /dotfile/load 2>/dev/null

xsh log info "/dotfile/install (no args = error)"
! xsh /dotfile/install 2>/dev/null

xsh log info "/dotfile/diff (no args = error)"
! xsh /dotfile/diff 2>/dev/null

xsh log info "/dotfile/edit (no args = error)"
! xsh /dotfile/edit 2>/dev/null

# restore HOME
export HOME=$__saved_home
unset XSH_DOTFILE_REPO

xsh log info "dotfile tests: all passed"

# TODO: Use the utilities's document (the section `Example`) to generate the
#       test cases.

exit
