function conf_auto_conf_interactive() {
    local variable=""
    local choice=""
    local conf_path=""

    echo "Please input any of the accepted values:"
    echo "y: to autoload module configuration"
    echo "n: to not autoload module configuration"

    # make up a variable for each module that have a conf path
    for module_name in ${!module_paths[@]}; do
        variable="conf_auto_${module_name}"
        conf_path="${module_name}_conf_path"

        if [[ -z "${!variable}" ]] && [[ -n "${!conf_path}" ]]; then
            printf -v $variable n
        fi
    done

    # call the interactive configurator
    conf_interactive conf_auto

    # propose to save all configs that should be autoload later now
    echo "Thanks, please input 'y' to run 'conf_auto_save_all'"
    read -p "Save configurations now? [y/n]" choice

    # save all configurations of modules that should be auto loaded
    if [[ "$choice" == "y" ]]; then
        conf_auto_save_all
    fi

    # check if .bash_logout calls conf_auto_save_all
    if [[ -f $HOME/.bash_logout ]]; then
        grep conf_auto_save_all $HOME/.bash_logout

        if [[ $? == 0 ]]; then
            return 0
        fi
    fi
    
    # tell the user about that trick
    echo "Tip: add 'conf_auto_save_all' in $HOME/.bash_logout"

    # propose to add it
    read -n 1 -p "Should autoloaded configurations also be autosaved? [y/n]" \
        choice

    # add it
    if [[ "$choice" == "y" ]]; then
        echo conf_auto_save_all >> $HOME/.bash_logout
        echo "Appended conf_auto_save_all to $HOME/.bash_logout"
    else
        # hack against read -n 1
        echo ""
    fi
}

function conf_auto_save_all() {
    for module_name in $(conf_auto_get_modules_to_autosave); do
        conf_save $module_name
    done
}
