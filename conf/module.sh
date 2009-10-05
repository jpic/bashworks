#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# All functions defined in this file take a module name as parameter, and are
# polite. Refer to the polite standard chapter in the documentation to figure
# how to overload the behaviour of any of these functions.
# The highest level function is conf which runs all functions declared in
# this file at some point. It makes configuring a module easy for the user,
# who has to type in bash:
# # conf yourmodule
# Medium level functions are conf_save(), conf_load() and
# conf_interactive() which only encapsulate the actual conf functions which
# are declared in functions.sh.
# Lowest level functions are conf_get_variables() and 
# conf_get_path(). The first outputs the name of the variables of the module
# for use in conf_save() and conf_interactive(), and the latter outputs the
# path to the module configuration file which is used by conf_save() and
# conf_load().
# @polite  All functions of this script are polite.

# Configure a module.
# Given a module name, it will load its configuration, prompt the user for
# changes and finnally save the changes.
# @calls   conf_load(), conf_interactive() and conf_save()
# @polite  Will try yourmodule_conf().
# @param   Module name
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

    mlog debug "Done configuring $module_name"
}

# Saves variables of a module in a file defined by the module.
# @calls   conf_get_variables(), conf_get_path(), conf_save_to_path()
# @polite  Will try yourmodule_conf_save().
# @param   Module name
function conf_save() {
    local module_name=$1
    local module_overload="${module_name}_conf_save"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    local module_variables=$(conf_get_variables $module_name)

    conf_save_to_path $(conf_get_path $module_name) $module_variables

    mlog debug "Saved configuration for $module_name"
}

# Loads variables of a module from a file defined by the module.
# 
# @calls   conf_get_path(), conf_load_from_path()
# @polite  Will try yourmodule_conf_load().
# @param   Module name
function conf_load() {
    local module_name=$1
    local module_overload="${module_name}_conf_load"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    conf_load_from_path $(conf_get_path $module_name)

    mlog debug "Loaded configuration for $module_name (${!conf_path})"
}

# This function interactively prompts the user to change the values of all
# variables of a module.
# For example, calling `conf_interactive yourmodule` will prompt the user to
# change values of all variables prefixed with yourmodule (ie.
# $yourmodule_conf_path, $yourmodule_preference ...)
# Note that this method does not save the new values.
# 
# @calls   conf_get_variables(), conf_interactive_variables()
# @polite  Will try yourmodule_conf_interactive().
# @param   List of variable names
function conf_interactive() {
    local module_name=$1
    local module_overload="${module_name}_conf_interactive"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    conf_interactive_variables $(conf_get_variables $module_name)
    
    mlog debug "Done interactive configuration for $module_name"
}

# This function outputs all variable names which are prefixed by the given 
# module name.
#
# WARNING: if the first element is a module name then eval will be used. If the
# eval string doesn't pass a regexp security test then 1 will be returned.
# @polite  Will try yourmodule_conf_get_variables().
# @return 1 Eval string did not pass the security check.
# @param   Module name
# @stdout  List of configuration variables of the module.
function conf_get_variables() {
    local module_name=$1

    local module_overload="${module_name}_conf_get_variables"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    local -a conf_variables=()
    local get_conf_variables='echo ${!'
    get_conf_variables+=$1
    get_conf_variables+='@}'

    echo $get_conf_variables | grep -q '^echo \${\![a-zA-Z0-9_]*@}$'
    if [[ $? != 0 ]]; then
        mlog alert "Eval line may be unsecure, abording: $get_conf_variables"
        return 1
    fi

    for variable in $(eval $get_conf_variables); do
        conf_variables+="${variable} "
    done

    echo $conf_variables
}

# This function outputs the path to a module configuration file. By default,
# it will use the value in $yourmodule_conf_path.
# @polite  Will try yourmodule_conf_get_path().
# @param   Module name
# @stdout  Path to the module configuration file.
function conf_get_path() {
    local module_name=$1

    local module_overload="${module_name}_conf_get_path"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    local conf_path="${module_name}_conf_path"

    echo ${!conf_path}
}
