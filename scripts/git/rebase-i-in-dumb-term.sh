#!/usr/bin/env bash

set -eo pipefail

#? Description:
#?   A shortcut of `git rebase -i`.
#?   If the term is dumb, an environment variable `EDITOR` is exported.
#?   This script works only on macOS.
#?
#? Usage:
#?   @rebase-i-in-dumb-term <SHA> [rebase-options]
#?
#? Options:
#?   <SHA>
#?
#?   The commit that will be rebased.
#?
#? Example:
#?   @rebase-i-in-dumb-term 96a2ea1318c710646df22c2e40df0b9b550a6c71
#?
#? Usecase:
#?   1. Use this for SourceTree's `Custom Actions`.
#?      Add a new action, then input:
#?      * Menu Caption:  `git interactive rebase(include current commit)`
#?      * Script to run: `bash`
#?      * Parameters:    `/path/to/rebase-i-in-dumb-term.sh $SHA^`
#?
function rebase-i-in-dumb-term () {

    # open (for macOS):
    #   -t: Causes the file to be opened with the default text editor, as determined
    #       via LaunchServices
    #   -W  Causes open to wait until the applications it opens (or that were already
    #       open) have exited. Use with the -n flag to allow open to function as an
    #       appropriate app for the $EDITOR environment variable.
    #   -n  Open a new instance of the application(s) even if one is already running.
    EDITOR=${EDITOR:-open -t -W -n}

    if [[ $TERM == 'dumb' ]]; then
        export EDITOR
    fi
    git rebase -i "$@"
}

rebase-i-in-dumb-term "$@"

exit
