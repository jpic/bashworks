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
    local module_defaults_setter="${module_name}_defaults_setter"
    local module_variables="${module_name}_variables[@]"

    if [[ -z $module_name ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    # unset all declared module variables
    for variable in ${!module_variables}; do
        unset $variable
    done
    
    # attempt to call yourmodule_defaults_setter()
    if [[ $(declare -f $module_defaults_setter) ]]; then
        $module_defaults_setter
    fi
}

#-------------------------- 
## Loads default and then load the config file
## @param Module name
#-------------------------- 
function conf_reload() {
    local usage="conf_reload \$module_name"
    local module_name="$1"
    local module_conf_loader="${module_name}_load"

    if [[ -z $module_name ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    conf_reset $module_name

    if [[ $(declare -f $module_conf_loader) ]]; then
        $module_conf_loader
    else
        conf_load $module_name
    fi
}

#-------------------------- 
## <p>Saves variables of a module in a file in a loadable format.</p>
## <p>
## Relies on conf_path_getter().
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
    # module variables array
    local module_variables="${module_name}_variables[@]"

    if [[ -z $module_name ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    module_conf_path=$(conf_path_getter $module_name $module_conf_path)

    # make sure that a zero status was returned
    local -i ret=$?
    if [[ $ret != 0 ]]; then
        return $ret
    fi

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

#-------------------------- 
## <p>Outputs a configuration file path.</p>
## <p>
## If the module configuration path param was not specified then it will try to
## to use $yourmodule_conf_path <b>after</b> trying to call
## yourmodule_conf_path_setter(), which <b>should</b> set $yourmodule_conf_path
## if it is declared.
## </p>
## @param Module name
## @param Module configuration path (optionnal)
## @return 2 If it could not save the module variables into a conf file.
#-------------------------- 
function conf_path_getter() {
    local usage="conf_path_getter \$module_name [\$module_conf_path]"
    local module_name="$1"
    local module_conf_path="$2"

    if [[ -n $module_conf_path ]]; then
        echo $module_conf_path
    fi

    if [[ -z $module_name ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    # conf path variable callback
    local module_conf_path_setter="${module_name}_conf_path_setter"
    # conf path variable
    local module_conf_path_varname="${module_name}_conf_path"
    
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
    
    echo "${!module_conf_path_varname}"
}

#-------------------------- 
## <p>Loads variables of a module from a filet.</p>
## <p>
## Relies on conf_path_getter()
## </p>
## @param Module name
## @param Module configuration path (optionnal)
## @return 2 If it could not load the module variables from a  conf file.
#-------------------------- 
function conf_load() {
    local usage="conf_save \$module_name [\$module_conf_path]"
    local module_name="$1"
    local module_conf_path="$2"

    if [[ -z $module_name ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    module_conf_path=$(conf_path_getter $module_name $module_conf_path)

    # make sure that a zero status was returned
    local -i ret=$?
    if [[ $ret != 0 ]]; then
        return $ret
    fi

    if [[ -f $module_conf_path ]]; then
        source $module_conf_path
    else
        jpic_print_warn "$module_conf_path does not exist, not loaded"
    fi
}

#-------------------------- 
## Interactive interface to module configuration
## @param Module name
#-------------------------- 
function conf_interactive() {
    local usage="conf_save \$module_name"
    local module_name="$1"
    local module_variables="${module_name}_variables[@]"

    conf_reload $module_name

    jpic_print_info "Configuration reloaded"

    for variable in ${!module_variables}; do
        local value="${!variable}"

        read -p "$variable [$value]: " input

        if [[ -n $input ]]; then
            declare $variable=$input
        fi
    done

    ${module_name}_conf_save
    ${module_name}_conf_load
}
