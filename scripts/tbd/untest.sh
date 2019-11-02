xsh_init() {
# Initalize userspace script environment,
# keep below vars value be correct in all situation
# Breaf:
#     1. set global var: DOT, PROGNAME
#     2: set trap for caller script
# Usage: Call this at BEGINNING (important!!!) of a script
#    #!/bin/sh
#    . profile
#    init || $exit 1

    # backup and clear all trap settings
    push '_xsh_trap' && _xsh_trap=$(trap_export) && trap_clean || return 1

    # send signal to trap this when you need to stop a sourced script from a function within it 
    trap 'return $_xsh_exit_code' 64 || return 1

    # to insure the uninit process would be executed in any case of script exiting
    trap '$exit' 0 SIGHUP SIGINT SIGTERM || return 1

    push '_xsh_dot' && _xsh_dot=$(ifdot 1) || return 1

    if [[ $xsh_auto_debug -eq 1 ]] ; then
        push '_xsh_progname' && _xsh_progname=$(progname 1) || return 1
    fi

    return 0
}
export -f xsh_init

init() {
# Initalize userspace script environment,
# keep below vars value be correct in all situation
# Breaf:
#     1. set global var: DOT, PROGNAME
#     2: set trap for caller script
# Usage: Call this at BEGINNING (important!!!) of a script
#    #!/bin/sh
#    . profile
#    init || $exit 1

    # Default to remove all temp and middle files and directories
    _TMP=0
    _MID=0

    # First time to call init()
    if [[ -z $PROGNAME ]] ; then
        # Save current trap
        _TRAP=$(trap)
        # Reset all traps first: 0 - 64
        trap $(seq 0 64)
    fi
    # Set necessary traps
    trap 'exit_status "$_STDERR" ; uninit ; return $_EXITCODE' 64 || return 1
    trap '$exit' SIGHUP SIGINT SIGTERM

    unset _EXITCODE

    _DOT=$(ifdot 1) || return 1
    _PROGNAME=$(progname 1) || return 1

    case $_DOT in
        0)  DOT=$_DOT && unset _DOT
            PROGNAME=$_PROGNAME && unset _PROGNAME
            ;;
        1)  push DOT && DOT=$_DOT && unset _DOT || return 1
            push PROGNAME && PROGNAME=$_PROGNAME && unset _PROGNAME || return 1
            ;;
        *)  return 1
            ;;
    esac
   
    print "environment initalized for this script, DOT: $DOT"

    return 0
}

xsh_uninit() {
# Un-initalize userspace script environment,
# keep below vars value be correct in all situation
# Breaf:
#     1. restore global var: DOT, PROGNAME
#     2. restore trap environment
# Usage: No need to call this manually

    local exit_code=$?

    if [[ -n $1 ]] ; then 
	exit_code=$1
    fi

    trap_reset && trap_import $_xsh_trap && pop '_xsh_trap' || return $exit_code

    if [[ $xsh_auto_tmpfs -eq 1 ]] ; then
	xsh_clean_tmpfs || return $exit_code
    fi

    if [[ $xsh_auto_debug -eq 1 ]] ; then
	pop '_xsh_progname' || return $exit_code
    fi

    if [[ $_xsh_dot -eq 0 ]] ; then
	exit $exit_code
    else
	_xsh_exit_code=$exit_code
	kill -s 64 $$
    fi
}
export -f xsh_uninit

uninit() {
# Un-initalize userspace script environment,
# keep below vars value be correct in all situation
# Breaf:
#     1. restore global var: DOT, PROGNAME
#     2. restore trap environment
# Usage: No need to call this manually

    print "un-initalizing environment for this script"
    # Clean temp files and directires
    clean

    case $DOT in
        0)  exit $_EXITCODE
            ;;
        1)  pop DOT PROGNAME || return 1

		    # Returning from the first time DOT call
		    if [[ -z $PROGNAME ]] ; then
		        print "returning from the first time DOT call"
		        # Reset all traps first: 0 - 64
		        trap $(seq 0 64)
		        # Restore saved trap
		        eval "$_TRAP"
		        unset _TRAP
		    fi
            ;;
    esac

    return 0
}

exit_status() {
# Get exit/return code into _EXITCODE and print message
# Usage: This function must be the first function all within the trap action which is trigerd at $exit
#     exit_status stderr_file

    local stderr=$1 arr_exit_msg

    # Analyse the error output file
    if [[ -s $stderr ]] ; then
        # Get all msg into array, including the DEFAULT exit code $? and the USER DEFINED exit code after $exit N
        eval arr_exit_msg=($(cat $stderr |awk -F: '{for(i=1;i<=NF;i++) { if (match($i, " kill") == 1) print $((i + 1)) }}' |sed -r 's/^|$/"/g'))

        # Get the USER DEFINED exit code if passed
        [[ -n ${arr_exit_msg[0]} ]] && arr_exit_msg[0]=$(echo "${arr_exit_msg[0]}" |sed -r 's/^ \(([0-9]+)\) - No such process$/\1/g')

        if [[ ${#arr_exit_msg[@]} -eq 1 && $(expr match "${arr_exit_msg}" '.*[^0-9].*') = 0 ]] ; then
            # Have USER DEFINED exit code (don't allow message), using it and ignoring DEFAULT exit code
            _EXITCODE=${arr_exit_msg}
            unset arr_exit_msg
        elif [[ ${#arr_exit_msg[@]} -gt 0 ]] ; then
            # Have message (don't allow USER DEFINED exit code), always set exit_code as 1
            _EXITCODE=1
        fi
    else
        # None USER DEFINED exit code and none message, using DEFAULT exit code
        _EXITCODE=$_DFTEXITCODE
    fi

    if [[ -z $_EXITCODE ]] ; then
        # All other case imply an error, set it at 9
        print "error on analysing exit code"
        _EXITCODE=9
    fi
    unset _DFTEXITCODE
    [[ -n ${arr_exit_msg[@]} ]] && print "${arr_exit_msg[@]}"

    return 0
}

reload() {
# Reload environment variables, and update all dependent variables.
# The reload variables is limited to be in $xsh_profile
# The update variables is limited to be in both $xsh_profile and the profile called this function
# Do not use $xsh_tmp_file, init() or print() within this function since it's used before init()
# Usage:
#     usr_profile:
#
#     usr_tmp=$xsh_tmp
#     usr_tmp_file=$usr_tmp/file
#     reload xsh_tmp=/new_value            # then both usr_xxx and usr_yyy are updated beside the new xsh_tmp
#
#     reload xsh_tmp="/tmp dir"           # blank space is allowed, but the quote is needed
#     reload xsh_tmp=/tmp xsh_tmp2=/tmp2  # multi-var is allowed

    [[ -z $1 ]] && return 0

    local pair name i 
    # Define the MAX level to recursivly call
    local max_level=10
    if [[ -z $p1 ]] ; then
        i=0
            local invoked_profile=$(progname -f 1) || return 1
            local p1=$xsh_tmp/$$.$RANDOM.p1
            local p2=$xsh_tmp/$$.$RANDOM.p2

        # Filter the profile and merge the \ ended lines
            awk NF $xsh_profile |awk '!/^[ \t]*#/' |sed -e :a -e '/\\$/N; s/\\\n//; ta' > $p1
            awk NF $invoked_profile |awk '!/^[ \t]*#/' |sed -e :a -e '/\\$/N; s/\\\n//; ta' > $p2
    else
        let i++
    fi

    while (test -n "$1")
    do
        pair="$1"
        # Add quote to escape blank space in the value
        pair=$(echo $pair |sed 's/=/&"/' |sed 's/$/"/')
        name=$(echo $pair |cut -d '=' -f1)

        if [[ $i -eq 0 ]] ; then
            # In the top call, only process variables within $xsh_profile
            grep -q "$name=" $p1 && eval "$pair" && \
                grep -q "export .$name" $p1 && export $name
        else
            # In the recursive call, find in $xsh_profile first, then profile called this function
            grep -q "$name=" $p1 && eval "$pair" && \
                grep -q "export .$name" $p1 && export $name || \
            grep -q "$name=" $p2 && eval "$pair" && \
                grep -q "export .$name" $p2 && export $name
        fi
        [[ $i -gt $max_level ]] && break

        # Collect the dependent variables and call this function recursivly
        # Below style is not seen as a dependence:
        #     var='$reloading_var'
        #     var=\$reloading_var
        eval reload $(grep -h ".=.*\$$name" $p1 $p2 |grep -v "='" |grep -v "[\]\$$name" |sed 's/export//' |sed "s/^/'/" |sed "s/$/'/")

        # To process the next pair 
        shift
    done

    # Remove the temp file manually since the uninit() is not valid here. 
    [[ $i -eq 0 ]] && rm -f $p1 $p2

    return 0
}
export -f reload


env.diff () {
# diff_env var /home/user/.bash_profile
# diff_env func /home/user/.bash_profile
# diff_env path /home/user/.bash_profile

    local -i brief
    case "$1" in
	-q)
	    brief=1
	    shift
	    ;;
    esac

    local profile1="$1"
    local profile2="$2"
    [[ -z "$profile1" || -z "$profile2" ]] && return 1

    local opt
    [[ $brief ]] && opt="-q"

     local -i result
    env.var.diff $opt "$profile1" "$profile2"
    $XSH_CHECK_ERROR
    result=$?

    env.func.diff $opt "$profile1" "$profile2"
    $XSH_CHECK_ERROR
    result=$(( result+$? ))

    return $result
}


env.exe.list() {
# list_prog
# list_prog /usr/bin /bin

    local paths="$@"
    [[ -z $paths ]] && paths="$(echo $PATH |sed 's/:/ /g')"

    local path
    for path in $paths
    do
	[[ -z $path ]] && break
	echo "$(find $path -executable -maxdepth 1 -type f -exec basename {} \;)" |xargs -I {} echo -e "\t" {}
    done
    return $?
}

env.func.list() {
    local opt="-f"

    case "$1" in
	"")
	    ;;
	-F)
	    opt="$1"
	    ;;
	*)
	    echo "WARNING: Invalid parameter: $1" 1>&2
	    ;;
    esac

    declare $opt
    return $?
}

env.func.ifdef() {
    return $?
}

env.func.getdef() {
# show function defination

    local function=$1
    [[ -z $function ]] && return 1
    #typeset -f $function
    declare -f $function
    return $?
}

env.func.opendef() {
# open function defination in editor

    local function=$1
    [[ -z $function ]] && return 1
    return $?
}

env.path.list() {
    echo $PATH |xargs -d: -n1 |sort
    return $?
}

env.user.id() {
    id |awk '{gsub(/.+=|\(.*\)/,"",$1); print $1}'
    return $?
}

env.user.name() {
    id |awk '{gsub(/.+\(|\)/,"",$1); print $1}'
    return $?
}

env.var.list() {
    declare |sed -n '/^[^ ]*=.*/p'
    return $?
}

env.var.ifdef() {
    local pattern=$(echo "$1" |sed -r 's/\[([0-9]+)\]/=.+\\[\1\\]/')
    pattern="^$pattern="
    return $(declare |awk "/$pattern/{n--}; END{print n+1}")
}

env.var.diff() {
    case "$1" in
	-q)
	    local brief=1
	    shift
	    ;;
    esac

    local profile1="$1"
    local profile2="$2"
    [[ -z "$profile1" || -z "$profile2" ]] && return 1

    if [[ $brief ]] ; then
	diff <( env.var.list -q "$profile1" ) <( env.var.list -q "$profile2" )
    else
	diff <( env.var.list "$profile1" ) <( env.var.list "$profile2" )
    fi
    return $?
#    diff <(env.var.list; env.func.list $opt) <(source "$profile" 2>&1>/dev/null; env.var.list; env.func.list $opt) |awk '/^>/' |sed 's/> //' |xargs -I {} echo -e "\t" {}
}
