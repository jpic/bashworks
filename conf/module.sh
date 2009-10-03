#--------------------------
## Configure a module.
##
## Given a module name, it will load its configuration, prompt the user for
## changes and finnally save the changes.
##
## Note: this function is polite, it will call yourmodule_conf() if it exists. It only calls polite conf_ functions.
## instead of doing the conf itself.
## @Param Module name
#--------------------------
function conf() {
    local module_name=$1
    local module_overload="${module_name}_conf"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
           $module_overload
           return $?
        fi
        echo lol
    fi

    conf_load $module_name
    conf_interactive $module_name
    conf_save $module_name
}

#--------------------------
## Saves variables of a module in a file defined by the module.
##
## For example, calling `conf_save yourmodule` will save all variables which
## name is prefixed by yourmodule_ in the file which path is in variable
## $yourmodule_conf_path.
##
## Note: this function is polite, it will call yourmodule_conf_save() if it
## exists instead of doing the saving itself.
## If yourmodule_conf_save() is actually the function calling conf_save() then
## it will execute itself.
##
## @Param   Module name
#--------------------------
function conf_save() {
    local module_name=$1
    local module_overload="${module_name}_conf_save"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    local module_variables=$(conf_get_module_variables $module_name)
    local module_save_path=${module_name}_conf_path

    conf_save_to_path ${!module_save_path} $module_variables

    mlog debug "Saved configuration for $module_name"
}

#--------------------------
## Loads variables of a module from a file defined by the module.
## 
## For example, calling `conf_load yourmodule` will get the config file path
## from variable $yourmodule_conf_path.
##
## Note: this function is polite, it will call yourmodule_conf_load() if it
## exists instead of doing the loading itself.
## If yourmodule_conf_load() is actually the function calling conf_load() then
## it will execute itself.
##
## @Param   Module namme
#--------------------------
function conf_load() {
    local module_name=$1
    local module_overload="${module_name}_conf_load"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    local conf_path="${module_name}_conf_path"

    conf_load_from_path ${!conf_path}

    mlog debug "Loaded configuration for $module_name (${!conf_path})"
}

#--------------------------
## This function interactively prompts the user to change the values of all
## variables of a module.
##
## For example, calling `conf_interactive yourmodule` will prompt the user
## to change values of all variables prefixed with yourmodule (ie.
## $yourmodule_conf_path, $yourmodule_preference ...)
## 
## Note: this function is polite, it will call yourmodule_conf_interactive() if
## it exists instead of doing the loading itself.
## If yourmodule_conf_interactive() is actually the function calling
## conf_interactive() then it will execute itself.
## 
## Note that this method does not save the new values.
##
## @param List of variable names
#--------------------------
function conf_interactive() {
    local module_name=$1
    local module_overload="${module_name}_conf_interactive"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    conf_interactive_variables $(conf_get_module_variables $module_name)
    
    mlog debug "Done interactive configuration for $module_name"
}
