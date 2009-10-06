#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Functions which overload default behavior of conf module functions are
# declared here. 
# conf_auto_get_variables() creates or uses variables which are named like
# $conf_auto_yourmodule. These variables are subject to change when the
# conf_module supports array.
# conf_auto_conf_interactive() overloads conf_interactive() for the conf_auto
# module and also helps the user to set up his bash environment.

# Create missing variables like $conf_auto_yourmodule for each module with
# default value "n", and then output the list of variables of conf_auto().
# @calls   conf_get_variables()
# @stdout  List of module variables.
function conf_auto_get_variables() {
    # make up a variable for each module that have a conf path
    for module_name in ${!module_paths[@]}; do
        variable="conf_auto_${module_name}"

        if [[ -z "${!variable}" ]] && [[ -n "${!conf_path}" ]]; then
            printf -v $variable "n"
        fi
    done

    conf_get_variables conf_auto
}

# Informs the user of acceptable variable values, proposes to save all current
# configuration and and helps him setting up the bashrc and bash_logout files
# if necessary.
# @stdout  Informations and prompts.
# @calls   conf_interactive()
# @log     Info, if bashrc or bash_logout was modified.
function conf_auto_conf_interactive() {
    local variable=""
    local choice=""
    local conf_path=""

    echo "Please input any of the accepted values:"
    echo "y: to autoload module configuration"
    echo "n: to not autoload module configuration"

    # call the interactive configurator
    # note: it will call conf_auto_get_variables.
    conf_interactive conf_auto

    # propose to save all configs that should be autoload later now
    echo "Thanks, please input 'y' to run 'conf_auto_save_all'"
    read -p "Save configurations now? [y/n]" choice

    # save all configurations of modules that should be auto loaded
    if [[ "$choice" == "y" ]]; then
        conf_auto_save_all
    fi

    # check if .bash_logout calls conf_auto_load_all
    grep -q conf_auto_load_all $HOME/.bashrc

    if [[ $? != 0 ]]; then
        # tell the user about that trick
        echo "Tip: function conf_auto_load_all() will load the config of"
        echo "all modules you choosed"
    
        # propose to add it
        read -n 1 -p "Append conf_auto_load_all in $HOME/.bashrc ? [y/n]" \
            choice
    
        # add it
        if [[ "$choice" == "y" ]]; then
            echo conf_auto_load_all >> $HOME/.bashrc
            mlog info "Appended conf_auto_load_all to $HOME/.bashrc"
        else
            # hack against read -n 1
            echo ""
        fi       
    fi

    # check if .bash_logout calls conf_auto_save_all
    grep -q conf_auto_save_all $HOME/.bash_logout

    if [[ $? != 0 ]]; then
        # tell the user about that trick
        echo "Tip: function conf_auto_save_all() will save the config of"
        echo "all modules you choosed"
    
        # propose to add it
        read -n 1 -p "Append conf_auto_save_all in $HOME/.bash_logout ? [y/n]" \
            choice
    
        # add it
        if [[ "$choice" == "y" ]]; then
            echo conf_auto_save_all >> $HOME/.bash_logout
            mlog info "Appended conf_auto_save_all to $HOME/.bash_logout"
        else
            # hack against read -n 1
            echo ""
        fi       
    fi
}
