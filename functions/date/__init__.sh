#? -----------------------------------------------------------------------------
#? xsh library INIT file.
#?
#? This file is sourced while importing any function utility, right before the
#? function utility was sourced.
#? -----------------------------------------------------------------------------


# mmddHHMMyyyy.ss
XSH_X_DATE__POSIX_FMT="+%m%d%H%M%Y.%S"

# yyyy-mm-dd
XSH_X_DATE__DATE_FMT="+%Y-%m-%d"

# HH:MM:SS
XSH_X_DATE__TIME_FMT="+%H:%M:%S"

# yyyy-mm-dd HH:MM:SS
XSH_X_DATE__DATETIME_FMT="+%Y-%m-%d %H:%M:%S"

# 1..7
XSH_X_DATE__WEEK_NUMBER_OF_WEEK_FMT="+%u"

# 1..53
XSH_X_DATE__WEEK_NUMBER_OF_YEAR_FMT="+%V"

# 2019
XSH_X_DATE__YEAR_FMT="+%Y"

# 01-12
XSH_X_DATE__MONTH_FMT="+%m"

# 01-31
XSH_X_DATE__DAY_FMT="+%d"

# 00-23
XSH_X_DATE__HOUR_FMT="+%H"

# 00-59
XSH_X_DATE__MINUTE_FMT="+%M"

# 00-60
XSH_X_DATE__SECOND_FMT="+%S"
