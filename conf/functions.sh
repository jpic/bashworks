#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# This file declares low level functions, which do not expect anything that
# concerns modules. For functions which expects modules see the script
# conf/module.sh.
# This script basically declares CRUD functions for given configuration file
# path and given set of configuration variables.
# Functions declared in this file are likely to change in future major
# versions because the features that could be added are:
# - array support in configurations,
# - better (hidden) password prompt support,
# - the user interface could use multiple frontends,
# Note that <a href="http://code.google.com/p/shesfw/">shesfw</a> is open
# source and has an (unfinished) user interface API with several backends
# which could be useable for example with new generation browsers like:
# - <a href="http://uzbl.org">uzbl</a>,
# - <a href="http://vimpression.org">vimpression</a>,
# - <a href="http://surf.suckless.org">surf</a>

# Saves given variables in the given configuration file.
# This function uses sed to update variables in the configuration file if
# the file contains a declaration of this variable. This is likely to be
# dropped in the future.
# Missing directories will be created if necessary.
# @param   Path to configuration file
# @param   List of variable names
function conf_save_to_path() {
    local conf_path="$1"

    if [[ ! $conf_path =~ "/" ]]; then
        mlog error "Not saving to '$conf_path': not an absolute path"
        return 1
    fi

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

    mlog debug "Saved to $conf_path: ${conf_variables[@]}"
}

# Loads a saved configuration file from a given configuration path.
# @param   Configuration file path
# @return 2 If the configuration file path does not exist or is not readable
function conf_load_from_path() {
    local conf_path="$1"

    if [[ -f $conf_path ]]; then
        source $conf_path
    else
        mlog notice "$conf_path does not exist, not loaded"
        return 2
    fi

    mlog debug "Loaded $conf_path"
}

# Prompt the user for variable value update, given a variable name list.
# Note that this method does not save the new values.
# @param   List of variable names, separated by space
function conf_interactive_variables() {
    local conf_variables="$*"
    local conf_value=""

    for variable in ${conf_variables}; do
        conf_value="${!variable}"

        read -p "\$$variable [$conf_value]: " input

        if [[ -n $input ]]; then
            printf -v $variable $input
            mlog info "Changed $variable to $input"
        fi
    done

    mlog debug "Configured ${conf_variables[@]}"
}
