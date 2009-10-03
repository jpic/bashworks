# cannot declare a global associative array in a function
declare -A mlog_levels

function mlog_post_source() {
    mlog_levels[trace]=0
    mlog_levels[debug]=1
    mlog_levels[info]=2
    mlog_levels[warn]=3
    mlog_levels[error]=4
    mlog_levels[fatal]=5
}

function mlog() {
    local level="$1"
    local message="$2"

    local GOOD=$'\e[32;01m'
    local WARN=$'\e[33;01m'
    local BAD=$'\e[31;01m'
    local NORMAL=$'\e[0m'


    case $level in
        trace)
            echo -e " -> $message" >&2
            ;;
        debug)
            echo -e " - $message" >&2
            ;;
        info)
	        echo -e " ${GOOD}*${NORMAL} $message" >&2
            ;;
        warn)
	        echo -e " ${WARN}*${NORMAL} $message" >&2
            ;;
        error)
	        echo -e " ${BAD}*${NORMAL} $message" >&2
            ;;
    esac
}
