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

__dotfile_test_dir=$(mktemp -d "${TMPDIR:-/tmp}/xsh-dotfile-test.XXXXXXXX")
trap 'rm -rf "$__dotfile_test_dir"' EXIT

# save originals — restored at the end of the dotfile block
__saved_home=$HOME
__saved_xsh_dotfile_repo=${XSH_DOTFILE_REPO:-}

# ============================================================
# Section 1 — XSH_DOTFILE_REPO env-var edge cases
# ============================================================

# --- 1a: XSH_DOTFILE_REPO unset → error ---
xsh log info "/dotfile/resolve (XSH_DOTFILE_REPO unset)"
unset XSH_DOTFILE_REPO
! xsh /dotfile/resolve 2>/dev/null
# verify the error message mentions the variable name
__err=$(xsh /dotfile/resolve 2>&1 || true)
[[ $__err == *"XSH_DOTFILE_REPO"* ]]

# --- 1b: XSH_DOTFILE_REPO set to empty string → error ---
xsh log info "/dotfile/resolve (XSH_DOTFILE_REPO empty)"
export XSH_DOTFILE_REPO=""
! xsh /dotfile/resolve 2>/dev/null

# --- 1c: XSH_DOTFILE_REPO points to non-existent directory → error ---
xsh log info "/dotfile/resolve (XSH_DOTFILE_REPO dir missing)"
export XSH_DOTFILE_REPO="$__dotfile_test_dir/no-such-dir"
! xsh /dotfile/resolve 2>/dev/null
__err=$(xsh /dotfile/resolve 2>&1 || true)
[[ $__err == *"not found"* ]]

# --- 1d: XSH_DOTFILE_REPO exists but has no .dotfilemap → error ---
xsh log info "/dotfile/resolve (no .dotfilemap)"
mkdir -p "$__dotfile_test_dir/empty-repo"
export XSH_DOTFILE_REPO="$__dotfile_test_dir/empty-repo"
! xsh /dotfile/resolve 2>/dev/null
__err=$(xsh /dotfile/resolve 2>&1 || true)
[[ $__err == *"map file not found"* ]]

# --- 1e: .dotfilemap exists but has only comments → error ---
xsh log info "/dotfile/resolve (empty .dotfilemap)"
mkdir -p "$__dotfile_test_dir/comments-only"
cat > "$__dotfile_test_dir/comments-only/.dotfilemap" <<'MAP'
# this file has no real entries
# just comments and blank lines

MAP
export XSH_DOTFILE_REPO="$__dotfile_test_dir/comments-only"
! xsh /dotfile/resolve 2>/dev/null
__err=$(xsh /dotfile/resolve 2>&1 || true)
[[ $__err == *"empty"* ]]

# --- 1f: valid XSH_DOTFILE_REPO → success ---
xsh log info "/dotfile/resolve (valid XSH_DOTFILE_REPO)"
__df_repo=$__dotfile_test_dir/repo
__df_home=$__dotfile_test_dir/home
mkdir -p "$__df_repo/bash" "$__df_repo/conf" "$__df_home/.config"

echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "repo-conf-content"    > "$__df_repo/conf/app.conf"
echo "home-profile-content" > "$__df_home/.profile"
echo "repo-conf-content"    > "$__df_home/.config/app.conf"

cat > "$__df_repo/.dotfilemap" <<MAP
bash/profile:$__df_home/.profile:source
conf/app.conf:$__df_home/.config/app.conf
MAP

export XSH_DOTFILE_REPO=$__df_repo
export HOME=$__df_home

__resolve_out=$(xsh /dotfile/resolve)
[[ $(echo "$__resolve_out" | wc -l | tr -d ' ') == 2 ]]

# --- 1g: all downstream commands respect XSH_DOTFILE_REPO ---
xsh log info "/dotfile/* (all commands use XSH_DOTFILE_REPO)"
__list_out=$(xsh /dotfile/list)
[[ $__list_out == *"bash/profile"* ]]

__status_out=$(xsh /dotfile/status)
[[ $__status_out == *"bash/profile"* ]]

__diff_out=$(xsh /dotfile/diff profile)
[[ $__diff_out == *"=== bash/profile ==="* ]]

__load_out=$(xsh /dotfile/load profile)
[[ $__load_out == *"LOAD"* ]]

echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "old" > "$__df_home/.profile"
__install_out=$(xsh /dotfile/install profile)
[[ $__install_out == *"INSTALL"* ]]

# ============================================================
# Section 2 — functional tests (resolve, list, status, etc.)
# ============================================================

# reset to a clean known state
echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "repo-conf-content"    > "$__df_repo/conf/app.conf"
echo "home-profile-content" > "$__df_home/.profile"
echo "repo-conf-content"    > "$__df_home/.config/app.conf"

# --- resolve ---
xsh log info "/dotfile/resolve (all entries)"
__resolve_out=$(xsh /dotfile/resolve)
[[ $(echo "$__resolve_out" | wc -l | tr -d ' ') == 2 ]]

xsh log info "/dotfile/resolve (filter by basename)"
__resolve_out=$(xsh /dotfile/resolve profile)
[[ $(echo "$__resolve_out" | wc -l | tr -d ' ') == 1 ]]
[[ $__resolve_out == *"bash/profile"* ]]

xsh log info "/dotfile/resolve (filter by repo path)"
__resolve_out=$(xsh /dotfile/resolve conf/app)
[[ $__resolve_out == *"conf/app.conf"* ]]

xsh log info "/dotfile/resolve (no match)"
! xsh /dotfile/resolve zzz_no_match 2>/dev/null

# --- list ---
xsh log info "/dotfile/list (all)"
__list_out=$(xsh /dotfile/list)
[[ $__list_out == *"bash/profile"* ]]
[[ $__list_out == *"[source]"* ]]
[[ $__list_out == *"conf/app.conf"* ]]

xsh log info "/dotfile/list (filtered)"
__list_out=$(xsh /dotfile/list profile)
[[ $__list_out == *"bash/profile"* ]]
# conf/app.conf should NOT appear
[[ $__list_out != *"conf/app.conf"* ]]

# --- status ---
xsh log info "/dotfile/status (mixed: modified + in-sync)"
__status_out=$(xsh /dotfile/status)
[[ $__status_out == *"[M] bash/profile"* ]]
[[ $__status_out == *"[=] conf/app.conf"* ]]

# --- diff ---
xsh log info "/dotfile/diff (modified file shows content)"
__diff_out=$(xsh /dotfile/diff profile)
[[ $__diff_out == *"=== bash/profile ==="* ]]
[[ $__diff_out == *"repo-profile-content"* ]]

xsh log info "/dotfile/diff (identical file — header only)"
__diff_out=$(xsh /dotfile/diff app.conf)
[[ $__diff_out == *"=== conf/app.conf ==="* ]]
[[ $(echo "$__diff_out" | wc -l | tr -d ' ') == 1 ]]

xsh log info "/dotfile/diff -g (GUI_DIFF_TOOL unset → error)"
unset GUI_DIFF_TOOL
! xsh /dotfile/diff -g profile 2>/dev/null

# --- load (HOME -> repo) ---
xsh log info "/dotfile/load (single)"
__load_out=$(xsh /dotfile/load profile)
[[ $__load_out == *"LOAD"* ]]
[[ $(cat "$__df_repo/bash/profile") == "home-profile-content" ]]

echo "repo-profile-content" > "$__df_repo/bash/profile"

xsh log info "/dotfile/load -a"
__load_out=$(xsh /dotfile/load -a)
[[ $(echo "$__load_out" | grep -c "LOAD") == 2 ]]

# --- install (repo -> HOME) ---
echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "old-home-content"     > "$__df_home/.profile"

xsh log info "/dotfile/install (single with post-install hint)"
__install_out=$(xsh /dotfile/install profile)
[[ $__install_out == *"INSTALL"* ]]
[[ $__install_out == *"source"* ]]
[[ $(cat "$__df_home/.profile") == "repo-profile-content" ]]

xsh log info "/dotfile/install -a"
echo "changed" > "$__df_repo/conf/app.conf"
__install_out=$(xsh /dotfile/install -a)
[[ $(echo "$__install_out" | grep -c "INSTALL") == 2 ]]
[[ $(cat "$__df_home/.config/app.conf") == "changed" ]]

xsh log info "/dotfile/install (creates parent dirs)"
cat >> "$__df_repo/.dotfilemap" <<MAP
conf/sub.conf:$__df_home/.config/sub/nested/sub.conf
MAP
echo "sub-content" > "$__df_repo/conf/sub.conf"
__install_out=$(xsh /dotfile/install sub.conf)
[[ -f "$__df_home/.config/sub/nested/sub.conf" ]]
[[ $(cat "$__df_home/.config/sub/nested/sub.conf") == "sub-content" ]]

# --- status after full sync ---
echo "repo-profile-content" > "$__df_repo/bash/profile"
echo "repo-profile-content" > "$__df_home/.profile"
echo "changed"              > "$__df_repo/conf/app.conf"

xsh log info "/dotfile/status (all in sync)"
__status_out=$(xsh /dotfile/status)
[[ $(echo "$__status_out" | grep -c "\[=\]") -ge 2 ]]

# --- status with missing files ---
rm "$__df_home/.profile"
xsh log info "/dotfile/status (home file missing)"
__status_out=$(xsh /dotfile/status profile)
[[ $__status_out == *"[!]"* ]]
[[ $__status_out == *"home file missing"* ]]

xsh log info "/dotfile/load (skip missing home file)"
__load_out=$(xsh /dotfile/load profile 2>&1)
[[ $__load_out == *"SKIP"* ]]

xsh log info "/dotfile/diff (skip missing home file)"
__diff_out=$(xsh /dotfile/diff profile 2>&1)
[[ $__diff_out == *"SKIP"* ]]

# --- argument validation ---
xsh log info "/dotfile/load (no args = error)"
! xsh /dotfile/load 2>/dev/null

xsh log info "/dotfile/install (no args = error)"
! xsh /dotfile/install 2>/dev/null

xsh log info "/dotfile/diff (no args = error)"
! xsh /dotfile/diff 2>/dev/null

xsh log info "/dotfile/edit (no args = error)"
! xsh /dotfile/edit 2>/dev/null

# ============================================================
# Cleanup — restore original env
# ============================================================
export HOME=$__saved_home
if [[ -n $__saved_xsh_dotfile_repo ]]; then
    export XSH_DOTFILE_REPO=$__saved_xsh_dotfile_repo
else
    unset XSH_DOTFILE_REPO
fi

xsh log info "dotfile tests: all passed"

# TODO: Use the utilities's document (the section `Example`) to generate the
#       test cases.

exit
