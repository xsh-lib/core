#? -----------------------------------------------------------------------------
#? xsh library INIT file.
#?
#? This file is sourced while importing any function utility, right before the
#? function utility was sourced.
#?
#? All variables except those of Array should be exported in order to be
#? available for the sub-processes.
#?
#? The variables of Array can't be exported to the sub-processes due to the
#? limitation of Bash.
#? -----------------------------------------------------------------------------


# mmddHHMMyyyy.ss
export XSH_X_DATE__POSIX_FMT="+%m%d%H%M%Y.%S"

# yyyy-mm-dd
export XSH_X_DATE__DATE_FMT="+%Y-%m-%d"

# HH:MM:SS
export XSH_X_DATE__TIME_FMT="+%H:%M:%S"

# yyyy-mm-dd HH:MM:SS
export XSH_X_DATE__DATETIME_FMT="+%Y-%m-%d %H:%M:%S"

# 1..7
export XSH_X_DATE__WEEK_NUMBER_OF_WEEK_FMT="+%u"

# 1..53
export XSH_X_DATE__WEEK_NUMBER_OF_YEAR_FMT="+%V"

# 2019
export XSH_X_DATE__YEAR_FMT="+%Y"

# 01-12
export XSH_X_DATE__MONTH_FMT="+%m"

# 01-31
export XSH_X_DATE__DAY_FMT="+%d"

# 00-23
export XSH_X_DATE__HOUR_FMT="+%H"

# 00-59
export XSH_X_DATE__MINUTE_FMT="+%M"

# 00-60
export XSH_X_DATE__SECOND_FMT="+%S"
