function docs_bashdoc() {
    local module_name="$1"
    local module_path="$(module_get_path $module_name)"

    export PROJECT="$module_name"
    export OUT_DIR="/tmp/$module_name"

    set $(find "$module_path" -name "*.sh")

    source $(module_get_path docs_bashdoc)/current/bashdoc.sh
}
