#? Description:
#?   Parse URI and return whether the URI is valid.
#?
#?   URI = scheme:[//authority]path[?query][#fragment]
#?   authority = [userinfo@]host[:port]
#?
#? Usage:
#?   @parser [OPTIONS] URI
#?
#? Options:
#?   -s    Output scheme.
#?   -a    Output authority.
#?   -u    Output user info.
#?   -h    Output host.
#?   -o    Output port.
#?   -p    Output path.
#?   -q    Output query.
#?   -f    Output fragment.
#?   URI   The Uniform Resource Identifier (URI).
#?
#? Output:
#?   The specified part of the URI.
#?
#? Return:
#?   0: Valid
#?   != 0: Invalid
#?
#? Example:
#?   $ @parser -s https://github.com
#?   https
#?
#? URI Samples:
#?
#?           userinfo       host      port
#?           ┌──┴───┐ ┌──────┴──────┐ ┌┴┐
#?   https://john.doe@www.example.com:123/forum/questions/?tag=networking&order=newest#top
#?   └─┬─┘   └───────────┬──────────────┘└───────┬───────┘ └───────────┬─────────────┘ └┬┘
#?   scheme          authority                  path                 query           fragment
#?
#?   mailto:John.Doe@example.com
#?   └─┬──┘ └────┬─────────────┘
#?   scheme     path
#?
#?   news:comp.infosystems.www.servers.unix
#?   └┬─┘ └─────────────┬─────────────────┘
#?   scheme            path
#?
#?   tel:+1-816-555-1212s
#?   └┬┘ └──────┬──────┘
#?   scheme    path
#?
#?   telnet://192.0.2.16:80/
#?   └─┬──┘   └─────┬─────┘│
#?   scheme     authority  path
#?
#?   urn:oasis:names:specification:docbook:dtd:xml:4.1.2
#?   └┬┘ └──────────────────────┬──────────────────────┘
#?   scheme                    path
#?
#? Bugs:
#?
#?   1. The scheme `ldap` is unsupported by now.
#?      The colon `:` within the authority of LDAP URI conflicts with port delimiter.
#?
#?      ldap://[2001:db8::7]/c=GB?objectClass?one
#?      └┬─┘   └─────┬─────┘└─┬─┘ └──────┬──────┘
#?      scheme   authority   path      query
#?
#? Link:
#?   * https://en.wikipedia.org/wiki/Uniform_Resource_Identifier
#?
function parser () {
    # get the last parameter
    local uri=${@:(-1)}

    #? Following regex is based on https://stackoverflow.com/a/45977232 by Patryk Obara.
    #? Extended to support new schemes, such as: file, mailto, news, tel and urn.
    #? The scheme `ldap` is not supported.
    #?
    declare -r uri_regex='^(([^:/?#]+):)?(//((([^/?#]+)@)?([^:/?#]+)(:([0-9]+))?)?)?((/)?([^?#]*))?(\?([^#]*))?(#(.*))?'
    #?                     ↑↑            ↑  ↑↑↑           ↑         ↑ ↑             ↑↑   ↑         ↑  ↑        ↑ ↑
    #?                     |2 scheme     |  ||6 userinfo  7 host    | 9 port        ||   12 rpath  |  14 query | 16 fragment
    #?                     1 scheme:     |  |5 userinfo@            8 :…            |11 /          13 ?…       15 #…
    #?                                   |  4 authority                             10 path
    #?                                   3 //…

    #? Patryk Obara's solution:
    
    #? # This solution in principle works the same as Adam Ryczkowski's, in this thread
    #? # - but has improved regular expression based on RFC3986, (with some changes) and
    #? # fixes some errors (e.g. userinfo can contain '_' character). This can also
    #? # understand relative URIs (e.g. to extract query or fragment).
    #? # 
    #? # Following regex is based on https://tools.ietf.org/html/rfc3986#appendix-B with
    #? # additional sub-expressions to split authority into userinfo, host and port
    #? # 
    #? readonly URI_REGEX='^(([^:/?#]+):)?(//((([^:/?#]+)@)?([^:/?#]+)(:([0-9]+))?))?(/([^?#]*))(\?([^#]*))?(#(.*))?'
    #? #                    ↑↑            ↑  ↑↑↑            ↑         ↑ ↑            ↑ ↑        ↑  ↑        ↑ ↑
    #? #                    |2 scheme     |  ||6 userinfo   7 host    | 9 port       | 11 rpath |  13 query | 15 fragment
    #? #                    1 scheme:     |  |5 userinfo@             8 :…           10 path    12 ?…       14 #…
    #? #                                  |  4 authority
    #? #                                  3 //…

    # parse and validate
    if [[ ! $uri =~ $uri_regex ]]; then
        printf "$FUNCNAME: ERROR: URI is not valid: '%s'.\n" "$uri" >&2
        return 255
    fi

    local OPTIND OPTARG opt

    while getopts sauhopqf opt; do
        case $opt in
            s)
                echo "${BASH_REMATCH[2]}"
                ;;
            a)
                echo "${BASH_REMATCH[4]}"
                ;;
            u)
                echo "${BASH_REMATCH[6]}"
                ;;
            h)
                echo "${BASH_REMATCH[7]}"
                ;;
            o)
                echo "${BASH_REMATCH[9]}"
                ;;
            p)
                echo "${BASH_REMATCH[10]}"
                ;;
            q)
                echo "${BASH_REMATCH[14]}"
                ;;
            f)
                echo "${BASH_REMATCH[16]}"
                ;;
            *)
                return 255
                ;;
        esac
    done
}
