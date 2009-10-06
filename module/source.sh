#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# @Synopsis     Bash modular application framework.
# @Copyright    Copyright 2009, James Pic
# @License      Apache, unless otherwise specified by a file or a comment.
#
# <h4>The KISS framework</h4>
# This file is the framework. It is *all* the framework. The framework is
# nothing else but this file. All other features, such as configuration
# management, unit testing, documentation, logging etc ... are done in
# separate, reuseable, consistent, simple modules.
#
# <h4>Framework variables</h4>
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
# A module is defined by a subdirectory of a repository with a source.sh file
# in it. That's all a module need. The module directory name is the name of the
# module. If hopefully it declares functions or variables then those should be
# prefixed by the module name and an underscore for example:
# yourmodule_somevar, yourmodule_somefunc.
# 
# A module may have dependencies and control of their loading is inversed,
# which means that specifically named functions may be declared in the module
# source.sh file if required by the module:
# - modulename_pre_source(): prepare for sourcing dependencies,
# - modulename_source(): load dependencies,
# - modulename_post_source(): prepare to be useable,
#
# These function may also check if the system its module is being load on is
# suitable or not, and call module_blacklist_add() otherwise. For example, if a
# module requires a linux-vserver kernel or a BSD system.
#
# <h4>Inversion of control and polite functions</h4>
# Inversion of control: the overall program's flow of control is not dictated
# by the caller, but by the framework. This applies for the framework and
# several modules, like conf, at a basic level, and in a polite way.
#
# Polite functions: Generic reuseable functions usually take a module name
# string argument. It should let the actual module to overload what is it about
# to process. For example, conf_save() is polite, calling `conf_save
# yourmodule` will first check if yourmodule_conf_save() exists, and run it
# then return 0 if it does. "Civilized coding" sucks way less than reinventing
# OOP in Bash.
# 
# That said, this is the general useage example:
#
##  # find all modules and submodules in your repo:
##  module_repo_add /path/to/your/repo
##  # pre source a module:
##  module_pre_source yourmodule # would call yourmodule_pre_source
##  # OR pre source all modules:
##  module_pre_source # would call yourmodule_pre_source for all modules
##  # then source a module:
##  module_source yourmodule # would call yourmodule_source
##  # OR source all modules:
##  module_source # would call yourmodule_call for all modules
##  # then post source a module:
##  module_post_source yourmodule # would call yourmodule_post_source
##  # OR post source all modules:
##  module_post_source # would call yourmodule_post_source for all modules
# 
# Or, run all at once:
#
##  module yourmodule # will do the pre_source, source and post_source
##  module # same, with all modules
#
# <h4>Module status</h4>
#
# A module status corresponds to the last thing that was done with it, for
# instance either of the following values:
# - *found*: the module source.sh file was found:
#   it is ready to source,
# - *source*: the module source.sh file was sourced:
#   it is ready to _pre_source(),
# - *pre_source()*: the module _pre_source() function was called:
#   it is ready to _source(),
# - *source()*: the module _source() function was called:
#   it is ready to _post_source(),
# - *post_source()*: the module _post_source() function was called:
#   it is ready to use,
# - *blacklist*: the module was blacklisted with module_blacklist_add(),
#
# The role of module.sh is to traverse application repository directories
# and try to load modules. Loading a module consist of:
# - finding source.sh
# - sourcing source.sh
# - running yourmodule_pre_source()
# - running yourmodule_source()
# - running yourmodule_post_source()
# Modules are also able to blacklist themselves.
# In order to find modules, this script expects repository paths either:
# - in the environment variable $MODULES_PATH (same format than $PATH)
# - as arguments of the source call (separate paths with space)
# - as arguments of module_pre_source (separate paths with space)
# Each module must have a source.sh file which can contain this functions:
# - yourmodule_pre_source(): basically set up variables needed by _source()
# - yourmodule_source(): include all dependencies
# - yourmodule_post_source(): initialise the module, ie. default variables,
#   conf path, whatever...
# Eventually, your module can have a yourmodule() function defined in source.sh
# to something meaningful. Think of it as an object constructor.
# Submodules are simply subdirectories of modules which contain source.sh. See
# module_pre_source() for more info.

# Check bash version. We need at least 4.0.x
# Lets not use anything like =~ here because
# that may not work on old bash versions.
#if [[ "$(awk -F. '{print $1 $2}' <<< $BASH_VERSION)" -lt 40 ]]; then
	echo "Sorry your bash version is too old!"
	echo "You need at least version 3.2 of bash"
	echo "Please install a newer version:"
	echo " * Either use your distro's packages"
	echo " * Or see http://www.gnu.org/software/bash/"
#	return 2
#fi

# string repo name => string repo absolute path
declare -A module_repo_paths
# string module name => string module absolute path
declare -A module_paths
# list of loaded modules
declare -A module_status

# (Re)-loads one or several modules.
# Keep in mind that module_source() is reponsible for calling
# yourmodule_pre_source() so for example:
##  module hack # will load the hack module
# @param module names separated by spaces
function module() {
    module_pre_source $*
    module_source $*
    module_post_source $*
}

# Load a module if not loaded.
# If this was called during a _pre_source or _source() function then it will
# add the module name to the load queue for later loading by
# module_load_queue().
# @param module names separated by spaces
function module_require() {
    for module_name in $*; do
        case ${module_status[$module_name]} in
            loaded)
                continue
                ;;
            blacklist)
                mlog error "Required module $module_name is blacklisted"
                return 2
                ;;
            *) # found, queued, but not loaded
                module_status[$module_name]="queued"
                ;;
        esac
    done

    if [[ ${FUNCNAME[@]} =~ _post_source ]] || [[ ! ${FUNCNAME[@]} =~ _source ]]; then
        module_queue_load
    fi
}

# Calls module() for each module with status "queued".
# @call module()
function module_queue_flush() {
    for module_name in ${!module_status[@]}; do
        if [[ ${module_status[$module_name]} == "queued" ]]; then
            module $module_name
        fi
    done
}

# This function finds all modules and nested submodules in a given path and
# registers it.
# With this example layout:
# - /yourpath/
# - /yourpath/foo/
# - /yourpath/foo/source.sh
# - /yourpath/foo/bar/source.sh
# It will register:
# - module "foo" with path "/yourpath/foo"
# - module "foo_bar" with path "/yourpath/foo/bar"
# It that example case, foo_bar functions should be prefixed by foo_bar_
# instead of just foo_.
# The blacklist check is done just before adding the module to $module_paths.
# @param   Paths to find modules in, separated by space.
# @calls   module_blacklist_check
function module_pre_source() {
    declare -a paths=($(echo $MODULES_PATH | tr : " "))

    if [[ -n $1 ]]; then
        declare -a paths=()

        for path in $*; do
            paths+=("$path")
        done
    fi

    for path in $(module_get_repo_paths); do
        paths+=("$path")
    done

    local module_name=""
    local relative_path=""
    local repo_name=""
    local len=0

    # register modules and paths for each path
    for path in ${paths[@]}; do
        if [[ ${path:(-1)} == "/" ]]; then
            len=$(( ${#path}-1 ))
            path="${path:0:$len}"
        fi

        if echo $OSTYPE | grep -q -o bsd; then
            path="$(realpath $path)"
        else
            path="$(readlink -f $path)"
        fi

        for module_path in `find $path -name source.sh -exec dirname {} \;`; do
            relative_path="${module_path#*$path/}"
            module_name="${relative_path//\//_}"
            
            # add to module_path if required
            if [[ ! "${!module_paths[@]}" =~ ^$module_name$ ]]; then
                module_paths["$module_name"]="$module_path"
            fi

            module_status[$module_name]="found"
        
        done

        repo_name="${path##*/}"
        module_repo_paths["$repo_name"]="$path"
    done
}

# Source, run _pre_source() and _source() for each modules. Module names can be
# passed as parameters, or all modules that where found will be used. This
# function cares about the possible blacklisting modules.
# It does the following for each module:
# - check blacklist
# - source source.sh
# - check blacklist
# - call _pre_source() function if it is declared
# - check blacklist
# - call _source() function if it is declared
# @param    optionnal list of modules, separated by space
# @calls    module_blacklist_check
function module_source() {
    local -a module_names=()
    local module_name=""
    local module_source_path=""
    local module_source=""

    if [[ -n $1 ]]; then
        module_names=$*
    else
        module_names=${!module_paths[@]}
    fi

    for module_name in ${module_names[@]}; do
        module_source_path="$(module_get_path $module_name)/source.sh"
        module_pre_source_function="${module_name}_pre_source"
        module_source_function="${module_name}_source"

        # blacklist check
        if [[ -n $(module_blacklist_check $module_name) ]]; then
            continue
        fi

        # source module source path
        source $module_source_path || echo "Could not source $module_source_path $module_name"
        
        # blacklist check
        if [[ -n $(module_blacklist_check $module_name) ]]; then
            continue
        fi
        
        # run module pre_source function if it is declared
        if [[ -n $(declare -f $module_pre_source_function) ]]; then
            $module_pre_source_function
        fi
        
        # blacklist check
        if [[ -n $(module_blacklist_check $module_name) ]]; then
            continue
        fi
        
        # run module source function if it is declared
        if [[ -n $(declare -f $module_source_function) ]]; then
            $module_source_function
        fi
    done
}

# Run _post_source() function for each selected module. Module names should be
# passed as parameter, separated by space. All found and non blacklisted
# modules are selected if no parameter is passed.
# It does following for each module:
# - check blacklist
# - unset any function or variable starting with blacklist module prefix,
# - call _post_source() function if it is declared.
# @param   optionnal list of modules, separated by space
# @calls   module_blacklist_check(), module_blacklist_check_unset()
function module_post_source() {    
    local module_post_source_function=""
    local module_names=$*

    if [[ -n $1 ]]; then
        module_names=$*
    else
        module_names=${!module_paths[@]}
    fi

    for module_name in ${!module_paths[@]}; do
        
        module_post_source_function="${module_name}_post_source"

        if [[ -z "$(module_blacklist_check $module_name)" ]] && \
            [[ -n "$(declare -f $module_post_source_function)" ]]; then
            $module_post_source_function
        fi

        module_blacklist_check_unset $module_name

        module_status[$module_name]="loaded"
    done
}

# Unsets a module if blacklisted, and if not "module"
# @calls module_blacklist_check(), module_unset()
function module_blacklist_check_unset() {
    local module_name="$1"
    
    # blacklist check
    if [[ -n $(module_blacklist_check $module_name) ]]; then
        # i won't unset myself
        if [[ "$module_name" != "module" ]]; then
            module_unset $to_unset
        fi
    fi
}

# Will unset anything starting with a given module prefix.
# @polite   Will try to run yourmodule_unset().
function module_unset() {
    local module_name="$1"

    # polite module snippet
    local module_overload="${module_name}_unset"
    if [[ -n $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi


    local declared=$(declare | grep -o "^${module_name}.*")
    local to_unset=""

    for word in $declared; do
        if [[ $word =~ ^$module_name ]]; then
            to_unset=$(echo $word| grep -o "^${module_name}[^=(]*")
            unset $to_unset
        fi
    done
}

# This function will output "Yes" if the first parameter it is called with
# is in the blacklist array.
# It will keep quiet (not output anything) it the first parameter is not
# in the blacklist array.
# Modules should not use $module_blacklist directly and should use this
# function to ensure that a module is blacklisted or not.
# Example usage:
#   if [[ -n $(module_blacklist_check yourmodule) ]]; then
#       echo "yourmodule is blacklisted"
#   else
#       echo "yourmodule is not blacklisted"
#   fi
# @param   Module name
function module_blacklist_check() {
    if [[ ${module_status[$1]}="blacklist" ]]; then
        echo "Yes"
        return 0
    fi

    return 1
}

# This function adds the first parameter to the blacklist.
# User modules should not use the $module_blacklist array dirrectly and
# should add modules to the blacklist through this function.
# User modules that do sanity checks should call this function if they
# cannot prepare to be useable.
# Example usage:
#   # add yourmodule to the blacklist
#   module_blacklist_add yourmodule
# @param    Module name
# @polite   Will try to call yourmodule_unset()
function module_blacklist_add() {
    module_status[$1]="blacklist"
}

# This function takes a module name as first parameter and outputs its
# absolute path.
# It provides a reliable way for a script in your module to know its own
# location on the file system.
# Example usage:
#   source $(module_get_path yourmodule)/functions.sh
# Example submodule usage:
#   source $(module_get_path yourmodule_submodule)/functions.sh
# @param   Module name
function module_get_path() {
    echo ${module_paths[$1]}
}

# Outputs the known module repository paths.
function module_get_repo_paths() {
    local paths=""
    
    for module_path in ${module_paths[@]}; do
        paths=" ${module_path%/*}"
    done

    echo $paths
}

# This function dumps all module variables.
function module_debug() {
    echo "For MODULES_PATH: $MODULES_PATH"

    echo "List of loaded modules and paths:"

    for module_name in ${!module_paths[@]}; do
        echo " - ${module_name} from ${module_paths[$module_name]}"
    done

    echo "List of repo names and paths":

    for repo_name in ${!module_repo_paths[@]}; do
        echo " - ${repo_name} from ${module_repo_paths[$repo_name]}"
    done

    echo "List of blacklisted modules:"

    for module_name in ${module_blacklist[@]}; do
        echo " - ${module_name} from ${module_paths[$module_name]}"
    done
}

# blacklist ourself because of course our structure is slightly different from
# others as we're one step in advance
module_blacklist_add module
