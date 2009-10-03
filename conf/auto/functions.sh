function conf_auto_get_modules_to_autosave() {
    local variable=""
    local output=""

    for module_name in ${!module_paths[@]}; do
        variable="conf_auto_${module_name}"

        if [[ "${!variable}" == "y" ]]; then
            output+="$module_name "
        fi
    done

    echo $output
}

function conf_auto_save_all() {
    for module_name in $(conf_auto_get_modules_to_autosave); do
        conf_save $module_name
    done
}

function conf_auto_load_decorator() {
    local module_name="$1"

    if [[ "$(conf_auto_get_modules_to_autosave)" =~ "$module_name" ]]; then
        conf_load $module_name
    fi
}
