# foo:desc:
# If the given expression is False, then give error message and exit current script.
# foo:usage:
# $foo $x -eq 0
#
# $foo -n $x
#
# $foo "$name" == "alex zhang"

xsh.assert ()
{
    eval [[ "$@" ]]
    local rc=$?
    if [[ ${rc} -ne 0 ]]; then
	echo "AssertionError: $@"
	exit ${rc}
    fi
}

# Description:
#   This function let you be able to use getopts in this way: -a v1 v2 v3 -b v1
#   It will set array OPTARG=(v1 v2 v3) for -a
#   Only works within getopts context
# Usage: 
#   foo "$@"; v=("${OPTARG[@]}")
xsh.get_optarg () 
{
    local optarg i

    # wrong usage
    [[ -z ${OPTIND} ]] && return 1

    optarg=${OPTARG}
    unset OPTARG
    OPTARG[0]=${optarg}
    i=1
    # if the next is not an option, then append it to array
    while [[ ${OPTIND} -le $# && ${!OPTIND:0:1} != '-' ]]; do
        OPTARG[${i}]=${!OPTIND} || return $?
        let i++ OPTIND++
    done
    return 0
}

xsh.bell ()
{
    local n=${1:-1}
    local i
    for i in $(seq 1 ${n}); do
        echo -ne \\a 1>&2
        [[ ${i} -lt ${n} ]] && sleep 0.5
    done
    echo
    return 0
}

# foo:desc
# Run a dos2unix on stdin, and output to stdout

# foo:usage:
# cat ./dos.txt | $foo

xsh.pipe_dos2unix ()
{
    if which dos2unix 2>&1 > /dev/null; then
	cat | dos2unix
    else
	cat | awk '{sub("\r$", ""); print}'
    fi
    return ${PIPESTATUS}
}

# foo:desc:
# Run a dos2unix on file $1, and output to stdout

# foo:usage:
# $foo ./dos.txt

xsh.dos2unix ()
{
    cat "$1" | xsh.pipe_dos2unix
    return ${PIPESTATUS}
}

# foo:desc
# Run a unix2dos on stdin, and output to stdout

# foo:usage:
# cat ./unix.txt | $foo

xsh.pipe_unix2dos ()
{
    if which unix2dos 2>&1 > /dev/null; then
	cat | unix2dos
    else
	cat | awk '{printf $0; if (match($0, "\r$") == 0) print "\r"; else print ""}'
    fi
    return ${PIPESTATUS}
}

# foo:desc:
# Run a unix2dos on file $1, and output to stdout

# foo:usage:
# $foo ./unix.txt

xsh.unix2dos ()
{
    cat "$1" | xsh.pipe_unix2dos
    return ${PIPESTATUS}
}

xsh.cat ()
{
    local rc=0
    while [[ $# -gt 0 ]]; do
	if file "$1" | grep -q compressed; then
	    if xsh.is_mac; then
		gzcat "$1"
	    else
		zcat "$1"
	    fi
	    rc=$((rc+$?))
	else
	    cat "$1"
	    rc=$((rc+$?))
	fi
	shift
    done
    return $rc
}

xsh.tts () {
# Speak out the passing words
# Usage: 
#     foo word1 [word2]

    local engine engine_exec

    for engine in "${XSH_TTS_ENGINES[@]}"; do
	if which "${engine}" 2>&1 >/dev/null; then
 	    local varname="XSH_TTS_ENGINES_$(xstr.upper "${engine}")"
	    engine_exec=${!varname}
	    break
	fi
    done

    if [[ ${engine_exec} ]]; then
	echo "$@" | ${engine_exec} 2>/dev/null
    else
	echo "No available TTS engine found." >&2
    fi
    return $?
}

