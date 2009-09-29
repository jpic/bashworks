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
## to use $yourmodule_conf_path <b>after</b> trying to call
## yourmodule_conf_path_setter(), which could set $yourmodule_conf_path.
## </p><p>
## Note that it will automatically try to create missing directories and inform
## the user.
## </p>
## @param Module name
## @param Module configuration path (optionnal)
## @return 2 If it could not save the module variables into a conf file.
#-------------------------- 
function conf_save() {
    local usage="conf_save \$module_name [\$module_conf_path]"
    local module_name="$1"
    local module_conf_path="$2"
    # conf path variable callback
    local module_conf_path_setter="${module_name}_conf_path_setter"
    # conf path variable
    local module_conf_path_varname="${module_name}_conf_path"
    # module variables array
    local module_variables="${module_name}_variables[@]"

    if [[ $module_name == "" ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    # if $2 was not specified
    # and ${module_name}_set_conf_path is a function
    if [[ -z $module_conf_path ]]; then
        if [[ $(declare -f $module_conf_path_setter) ]]; then
            # run the function
            $module_conf_path_setter

            if [[ -z ${!module_conf_path_varname} ]]; then
                jpic_print_error "Dying: $module_conf_path_setter() did not set \$$module_conf_path"
                jpic_print_error "Usage: $usage"
                return 2
            fi
        elif [[ -z ${!module_conf_path_varname} ]]; then
            jpic_print_error "Dying: could not figure ${module_name} conf path"
            jpic_print_error "Usage: $usage"
            return 2
        fi
    fi
    
    module_conf_path="${!module_conf_path_varname}"

    if [[ ! -f $module_conf_path ]]; then
        local directory=${module_conf_path%/*}

        if [[ $directory != $module_conf_path ]] && [[ ! -d $directory ]]; then
            # make required directories
            mkdir -p $directory
            jpic_print_info "Created $directory for $module_conf_path"
        fi

        touch $module_conf_path
    fi

    for variable in ${!module_variables}; do
        local value="${!variable}"
    
        grep -q "^${variable}=\"[^\"]*\"$" $module_conf_path
    
        if [[ $? -eq 0 ]]; then
            sed -i -e "s@^${variable}=.*@${variable}=\"$value\"@" $module_conf_path
        else
            echo "${variable}=\"${value}\"" >> $module_conf_path
        fi
    done
}
