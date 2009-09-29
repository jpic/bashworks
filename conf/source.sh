#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Persistent configuration handler for jpic framework.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#-------------------------- 
## <p>Reset module variables.</p>
## <p>
## After unsetting all variables named in $yourmodule_variables,
## it will attempt to call yourmodule_defaults_setter().
## </p>
## @param Module name
#-------------------------- 
function conf_reset() {
    local usage="conf_reset \$module_name"
    local module_name="$1"
    local module_variable_names="${module_name}_variables"
    local module_defaults_setter="${module_name}_defaults_setter"

    if [[ $module_name == "" ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    # unset all declared module variables
    for variable in $module_variable_names; do
        unset $variable
    done
    
    # attempt to call yourmodule_defaults_setter()
    if [[ $(declare -f $module_defaults_setter) ]]; then
        $module_defaults_setter
    fi
}

#-------------------------- 
## <p>Saves variables of a module in a file in a loadable format.</p>
## <p>
## If the module configuration path param was not specified then it will try to
## to use $yourmodule_config_path <b>after</b> trying to call
## yourmodule_config_path_setter(), which could set $yourmodule_config_path.
## </p><p>
## Note that it will automatically try to create missing directories and inform
## the user.
## </p>
## @param Module name
## @param Module configuration path (optionnal)
## @return 2 If it could not save the module variables into a config file.
#-------------------------- 
function conf_save() {
    local usage="conf_save \$module_name [\$module_config_path]"
    local module_name="$1"
    local module_config_path="$2"
    # config path variable callback
    local module_config_path_setter="${module_name}_set_config_path"
    # config path variable
    local module_config_path_varname="${module_name}_config_path"
    # module variables array
    local module_variables="${module_name}_variables[@]"

    if [[ $module_name == "" ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    # if $2 was not specified
    # and ${module_name}_set_config_path is a function
    if [[ -z $module_config_path ]]; then
        if [[ $(declare -f $module_config_path_setter) ]]; then
            # run the function
            $module_config_path_setter

            if [[ -z $module_config_path ]]; then
                jpic_print_error "Dying: $module_config_path_setter() did not set \$$module_config_path"
                jpic_print_error "Usage: $usage"
                return 2
            fi
        # and ${module_name}_config_path is not a non-zero variable
        elif [[ -n ${!module_config_path_varname} ]]; then
            # use that variable
            module_config_path="${!module_config_path_varname}"
        else
            jpic_print_error "Dying: could not figure ${module_name} config path"
            jpic_print_error "Usage: $usage"
            return 2
        fi
    fi

    if [[ ! -f $module_config_path ]]; then
        local directory=${module_config_path%/*}

        if [[ $directory != $module_config_path ]]; then
            # make required directories
            mkdir -p $directory
            jpic_print_info "Created $directory for $module_config_path"
        fi

        touch $module_config_path
    fi

    for variable in ${!module_variables}; do
        local value="${!variable}"
    
        grep -q "^${variable}=\"[^\"]*\"$" $module_config_path
    
        if [[ $? -eq 0 ]]; then
            sed -i -e "s@^${variable}=.*@${variable}=\"$value\"\$@" $module_config_path
        else
            echo "${variable}=\"${value}\"" >> $module_config_path
        fi
    done
}
