# cannot declare a global associative array in a function
declare -A mlog_levels

function mlog_source() {
    source $(module_get_path mlog)/bashinator-0.3.sh
}

function mlog_post_source() {
    conf_auto_load_decorator mlog
}

function mlog() {
    local level="$1"
    local message="$2"

    __msg $level $message
}
