#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Persistent configuration handler functions.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## This functtion takes a module name as first parameter and outputs the
## name of all declared variables prefixed by it, separated by spaces.
##
## WARNING: if the first element is a module name then eval will be used. If the
##          eval string doesn't pass a regexp security test then 1 will be
##          returned.
## @Param   Module name
#--------------------------
function conf_get_module_variables() {
    local -a conf_variables=()
    local get_conf_variables='echo ${!'
    get_conf_variables+=$1
    get_conf_variables+='@}'

    echo $get_conf_variables | grep -q '^echo \${\![a-zA-Z0-9_]*@}$'
    if [[ $? != 0 ]]; then
        print_error "Eval line may be unsecure, abording: $get_conf_variables"
        return 1
    fi

    for variable in $(eval $get_conf_variables); do
        conf_variables+="${variable} "
    done

    echo $conf_variables
}

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
function conf_save_to_path() {
    local conf_path="$1"

    if [[ ! $conf_path =~ "/" ]]; then
        print_error "Not saving to '$conf_path': not an absolute path"
        return 1
    fi

    local conf_variables="$*"
    # Skip the first parameter which is for $conf_path
    conf_variables=${conf_variables#* }
    
    print_debug Will save ${conf_variables} to ${conf_path}

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
function conf_load_from_path() {
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
function conf_interactive_variables() {
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
