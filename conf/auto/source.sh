function conf_auto_source() {
    source $(module_get_path conf_auto)/functions.sh
    source $(module_get_path conf_auto)/conf.sh
}

function conf_auto_post_source() {
    conf_auto_conf_path="$HOME/.conf_auto"
    conf_load conf_auto

    local variable=""

    for module_name in ${!module_paths[@]}; do
        variable="conf_auto_${module_name}"

        if [[ "${!variable}" == "y" ]]; then
            print_debug "autoloading configuration for $module_name"
            conf_load $module_name
        fi
    done
}
