#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Persistent configuration handler functions.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#-------------------------- 
## This function saves given variables in a given configuration file.
##
## This function is not only able of writing but can also update variables
## in the file without altering the other contents.
##
## Missing directories will be created if the passed path parameter contains any.
##
## @Param   Path to configuration file
## @Param   List of variable names
#-------------------------- 
function conf_save() {
    local conf_path="$1"
    local conf_variables="$*"
    # Skip the first parameter which is for $conf_path
    conf_variables=${conf_variables#* }
    local conf_value=""

    if [[ ! -f $conf_path ]]; then
        local directory=${conf_path%/*}

        if [[ $directory != $conf_path ]] && [[ ! -d $directory ]]; then
            # make required directories
            mkdir -p $directory
        fi

        touch $conf_path
    fi

    for variable in ${conf_variables[@]}; do
        conf_value="${!variable}"
    
        grep -q "^${variable}=\"[^\"]*\"$" $conf_path
    
        if [[ $? -eq 0 ]]; then
            sed -i -e "s@^${variable}=.*@${variable}=\"${conf_value}\"@" $conf_path
        else
            echo "${variable}=\"${conf_value}\"" >> $conf_path
        fi
    done
}

#-------------------------- 
## This function loads the variables from a given configuration file.
##
## It will print an error message if the configuration file cannot be read.
##
## @Param   Configuration file path
## @Return  2 If the configuration file path does not exist or is not readable
#-------------------------- 
function conf_load() {
    local conf_path="$1"

    if [[ -f $conf_path ]]; then
        source $conf_path
    else
        print_error "$conf_path does not exist, not loaded"
        return 2
    fi
}

#-------------------------- 
## This function interactively prompts the user for variable value change
## given a variable name list.
##
## Note that this method does not save the new values.
##
## @param List of variable names
#-------------------------- 
function conf_interactive() {
    local conf_variables="$*"
    local conf_value=""

    for variable in ${conf_variables}; do
        conf_value="${!variable}"

        read -p "\$$variable [$conf_value]: " input

        if [[ -n $input ]]; then
            printf -v $variable $input
            echo "Changed $variable to $input"
        fi
    done
}
