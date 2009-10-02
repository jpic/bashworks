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
