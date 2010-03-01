#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# @Synopsis     Bash modular application framework.
# @Copyright    Copyright 2009, James Pic
# @License      Apache, unless otherwise specified by a file or a comment.
#
# <h4>The dumb framework</h4>
#
# This file is the framework. It is *all* the framework. The framework is
# nothing else but this file. All other features, such as configuration
# management, unit testing, documentation, logging etc ... are done in
# separate, reuseable, consistent, simple modules.
#
# <h4>Framework variables</h4>
#
# The role of this framework is to manage repositories of modules with the
# following variables:
# - $module_repo_paths is an associative array of :
#   repo name => repo absolute path
# - $module_paths is an associative array of:
#   module name => module absolute path
# - $module_status is an associative array of:
#   module name => module status (string)
# 
# <h4>Definition of a module</h4>
#
# A module is defined by a subdirectory of a repository with a source.sh file
# in it. That's all a module need. The module directory name is the name of the
# module. If hopefully it declares functions or variables then those should be
# prefixed by the module name and an underscore for example:
# yourmodule_somevar, yourmodule_somefunc.
# 
# A module may have dependencies and control of their loading is inversed,
# which means that specifically named functions may be declared in the module
# source.sh file if required by the module:
# - modulename_pre_load(): prepare for sourcing dependencies,
# - modulename_load(): load dependencies,
# - modulename_post_load(): prepare to be useable,
#
# These function may also check if the system its module is being load on is
# suitable or not, and call module_unset() otherwise. For example, if a
# module requires a linux-vserver kernel or a BSD system.
#
# <h4>Inversion of control and polite functions</h4>
#
# Inversion of control: the overall program's flow of control is not dictated
# by the caller, but by the framework. This applies for the framework and
# several modules, like conf, at a basic level, and in a polite way.
#
# Polite functions: Generic reuseable functions usually take a module name
# string argument. It should let the actual module to overload what is it about
# to process. For example, conf_save() is polite, calling `conf_save
# yourmodule` will first check if yourmodule_conf_save() exists, and run it
# then return 0 if it does. Note that an overloading function can call its
# caller. "Civilized coding" sucks way less than reinventing OOP in Bash.
# 
# That said, this is the general useage example:
#
##  # add your repo:
##  module_repo_add /path/to/yourrepo
##  # find modules and submodules in your repo:
##  module_repo yourrepo
##  # source a module:
##  module_source yourmodule # would call yourmodule_source
##  # pre load a module:
##  module_pre_load yourmodule # would call yourmodule_pre_load
##  # then load a module:
##  module_load yourmodule # would call yourmodule_load
##  # then post load a module:
##  module_post_load yourmodule # would call yourmodule_post_load
# 
# Or, run all at once:
#
##  module_repo_use /path/to/yourrepo
##  module yourmodule # will do the source, pre_load, load and post_load
##  module # same, with all modules
#
# <h4>Module status</h4>
#
# A module status corresponds to the last thing that was done with it, for
# instance either of the following values:
# - *find*: the module source.sh file was found:
#   it is ready to source,
# - *source*: the module source.sh file was sourced:
#   it is ready to _pre_load(),
# - *pre_load*: the module _pre_load() function was called:
#   it is ready to _load(),
# - *load*: the module _load() function was called:
#   it is ready to _post_load(),
# - *post_load*: the module _post_load() function was called:
#   it is ready to use,
#
# <h4>Module dependencies</h4>
#
# Some research should be done, a possibility is a "loading queue"
# implementation.
#
# For now, call the module_load_core_modules() function before loading really
# optionnal modules.
# 
# <h4>License agreement</h4>
#
# You swear that:
# - you will never use trailing slashes in paths,
# - you will always prefix your variables and functions correctly,
# - you will not pollute the environment with temporary variables,
# - you will not break backward compatibility, unless you warned,

# Check bash version. We need at least 4.0.x
# Lets not use anything like =~ here because
# that may not work on old bash versions.
#if [[ "$(awk -F. '{print $1 $2}' <<< $BASH_VERSION)" -lt 40 ]]; then
	#echo "Sorry your bash version is too old!"
	#echo "You need at least version 3.2 of bash"
	#echo "Please install a newer version:"
	#echo " * Either use your distro's packages"
	#echo " * Or see http://www.gnu.org/software/bash/"
	#return 2
#fi

# string repo name => string repo absolute path
declare -A module_repo_paths

# string module name => string module absolute path
declare -A module_paths

# string module name => string module status
declare -A module_status

# Temporary solution against module dependencies
function module_load_core_modules() {
    module hack conf mlog
}

# (Re)-loads one or several module repository. See module/source.sh file
# documentation.
# @param repository names separated by spaces
function module_repo() {
    module_repo_add $*
    module_repo_find ${!module_repo_paths[@]}
}

# (Re)-loads one or several modules. See module/source.sh file documentation.
# @param module names separated by spaces
function module() {
    module_source $*
    module_pre_load $*
    module_load $*
    module_post_load $*
}

# Adds one or several repo path after removing the trailing slash.
#
# If anything is strange, then use absolute paths.
#
# @param path to repositories separated by spaces
# @variable $module_repo_paths is updated
function module_repo_add() {
    local abs_path=""
    local repo_name=""
    local len=0

    while [[ -n "$1" ]]; do
        
        # in case hack module is not loaded yet, then hack_realpath should
        # not be depended on.
        if [[ $OSTYPE =~ bsd ]]; then
            abs_path="$(realpath $1)"
        else
            abs_path="$(readlink -f $1)"
        fi

        if [[ ${abs_path:(-1)} == "/" ]]; then
            len=$(( ${#abs_path}-1 ))
            abs_path="${abs_path:0:$len}"
        fi

        repo_name="${abs_path##*/}"
        module_repo_paths[$repo_name]="$abs_path"

        shift
    done
}

# This function finds all modules and nested submodules in a given repo.
#
# With this example layout:
# - /yourpath/
# - /yourpath/foo/
# - /yourpath/foo/source.sh
# - /yourpath/foo/bar/source.sh
#
# It will register:
# - module "foo" with path "/yourpath/foo"
# - module "foo_bar" with path "/yourpath/foo/bar"
#
# It that example case, foo_bar functions should be prefixed by foo_bar_
# instead of just foo_.
#
# @param    repository names separated by spaces
# @variable $module_paths and $module_status are updated
# @variable $module_repo_paths is read
function module_repo_find() {
    local path=""
    local module_path=""
    local module_name=""
    local rel_path=""

    while [[ -n "$1" ]]; do
        
        path=${module_repo_paths[$1]}

        for module_path in `find $path -name source.sh -exec dirname {} \;`; do

            rel_path="${module_path#*$path/}"
            module_name="${rel_path//\//_}"
            
            module_paths[$module_name]="$module_path"
            module_status[$module_name]="find"
        
        done
        
        shift
    done
}

# Sources the source.sh file of the given modules
# @param    module names, separated by space
# @variable $module_paths is read
# @variable $module_status is updated
# @polite   will try yourmodule_source(), useful for reloading control
function module_source() {
    while [[ -n "$1" ]]; do
    
        local module_source="${1}_source"
        if [[ -n "$(declare -f $module_source)" ]]; then
            $module_source
        else
            source ${module_paths[$1]}/source.sh
        fi  

        module_status[$1]="source"
        
        shift
    done
}

# Run the _pre_load() function of any given module.
# @param    module names, separated by space
# @variable $module_status is updated
# @calls    yourmodule_pre_load()
function module_pre_load() {
    while [[ -n "$1" ]]; do
        
        local module_pre_load="${1}_pre_load"
        if [[ -n "$(declare -f $module_pre_load)" ]]; then
            $module_pre_load
        fi

        module_status[$1]="pre_load"
        
        shift
    done
}

# Run the _load() function of any given module.
# @param    module names, separated by space
# @variable $module_status is updated
# @calls    yourmodule_load()
function module_load() {
    while [[ -n "$1" ]]; do
        
        local module_load="${1}_load"
        if [[ -n "$(declare -f $module_load)" ]]; then
            $module_load
        fi

        module_status[$1]="load"
        
        shift
    done
}

# Run the _post_load() function of any given module.
# @param    module names, separated by space
# @variable $module_status is updated
# @calls    yourmodule_post_load()
function module_post_load() {
    while [[ -n "$1" ]]; do
        
        local module_post_load="${1}_post_load"
        if [[ -n "$(declare -f $module_post_load)" ]]; then
            $module_post_load
        fi

        module_status[$1]="post_load"
        
        shift
    done
}

# Will unset anything starting with given module names.
# This function should be called if a module figures that the system is not
# suitable.
# @param    module names, separated by space
# @polite   Will try to run yourmodule_unset().
function module_unset() {
    local word=""
    
    while [[ -n "$1" ]]; do

        # polite module snippet
        local module_overload="${1}_unset"
        if [[ -n "$(declare -f $module_overload)" ]]; then
            if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
                $module_overload
                return $?
            fi
        fi

        local declared=$(declare | grep -o "^${1}.*")

        for word in $declared; do
            if [[ $word =~ ^$1 ]]; then
                local to_unset=$(echo $word| grep -o "^${1}[^=(]*")
                unset $to_unset
            fi
        done

        shift
    done
}

# This function takes a module name as first parameter and outputs its
# absolute path.
# It provides a reliable way for a script in your module to know its own
# location on the file system.
# This function is used by any module _load() function.
# Example usage:
#   source $(module_get_path yourmodule)/functions.sh
# Example submodule usage:
#   source $(module_get_path yourmodule_submodule)/functions.sh
# @param   Module name
function module_get_path() {
    echo ${module_paths[$1]}
}

# This function dumps all module variables.
function module_debug() {
    echo "List of repo names and paths":

    for repo_name in ${!module_repo_paths[@]}; do
        echo " - ${repo_name} from ${module_repo_paths[$repo_name]}"
    done

    echo "List of loaded modules, statuses and paths:"

    for module_name in ${!module_paths[@]}; do
        echo " - ${module_name}, ${module_status[$module_name]} from ${module_paths[$module_name]}"
    done
}
