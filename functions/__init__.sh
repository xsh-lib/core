#? -----------------------------------------------------------------------------
#? xsh library INIT file.
#?
#? This file is sourced while importing any function utility, right before the
#? function utility was sourced.
#?
#? The source of the init file won't happen again on the subsequence calls of
#? the function utility until it is imported again, except a `runtime` decorator
#? is used on the init file.
#?
#? All variables except those of Array should be exported in order to be
#? available for the sub-processes.
#?
#? The variables of Array can't be exported to the sub-processes due to the
#? limitation of Bash.
#? -----------------------------------------------------------------------------
