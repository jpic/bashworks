#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Bash modular application framework.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
##
## The role of module.sh is to traverse application repository directories
## and try to load modules. Loading a module consist of:
## - finding source.sh,
## - sourcing source.sh,
## - running yourmodule_source()
## - running yourmodule_init()
##
## Modules are also able to blacklist themselves.
##
## In order to find modules, this script expects the environment variable
## $MODULES_PATH to be set just like $PATH.
##
## Role of source.sh:
## Each module should have a source.sh file which may contain two functions:
## - yourmodule_source(),
## - yourmodule_init()
##
## Role of yourmodule_source():
## This function should only import the submodules it needs with module_local_source().
##
## Role of yourmodule_init():
## This function is free to do whatever it should to make the module ready for usage.
#--------------------------

# Check bash version. We need at least 4.0.x {{{
# Lets not use anything like =~ here because
# that may not work on old bash versions.
if [[ "$(awk -F. '{print $1 $2}' <<< $BASH_VERSION)" -lt 40 ]]; then
	echo "Sorry your bash version is too old!"
	echo "You need at least version 3.2 of bash"
	echo "Please install a newer version:"
	echo " * Either use your distro's packages"
	echo " * Or see http://www.gnu.org/software/bash/"
	return 2
fi
# }}}
if [[ -z $MODULES_PATH ]]; then # {{{ return if $MODULES_PATH is not defined
    echo "Sorry, MODULES_PATH is not defined"
    echo "MODULES_PATH should contain a list of paths like the PATH variable"
    echo "It should contain a list of directories containing modules"
    echo "Each directory should be separated by ':'"
    echo "A module should be a folder with a file called 'source.sh' in it."
	return 2
fi
# }}}

#--------------------------
## Resets module variables (ie. $module_paths and $module_blacklist).
## Traverses $MODULES_PATH searching for modules (directories with source.sh)
## Runs modulename_source() if it exists.
## Addes module names and paths to $module_paths.
## This function checks if the module was blacklisted at each step.
## @Globals  module_paths, module_blacklist
#--------------------------
function module_source() {
    # string module name => string module absolute path
    unset module_paths
    declare -A module_paths
    
    # list of module names
    unset module_blacklist    
    declare -a module_blacklist

    # make an array of MODULES_PATH
    declare -a paths=($(echo $MODULES_PATH | tr : " "))

    local module_name=""
    local module_path=""
    local module_source_path=""
    local module_source=""

    # start registering to module_paths and sourcing
    for path in ${paths[@]}; do        
        for module_path in ${path}/*; do
            
            module_name="${module_path##*/}"
            
            # blacklist check
            if [[ $(module_blacklist_check $module_name) ]]; then
                continue
            fi
            
            # add to module_path
            module_paths[$module_name]=$module_path

        done
    done

    for module_name in ${!module_paths[@]}; do
        module_path="${module_paths[$module_name]}"
        module_source_path="${module_path}/source.sh"
        module_source_function="${module_name}_source"

        if [[ ! -f $module_source_path ]]; then
            continue
        fi

        # blacklist check
        if [[ $(module_blacklist_check $module_name) ]]; then
            continue
        fi

        # source module source path
        source $module_source_path
        
        # blacklist check
        if [[ $(module_blacklist_check $module_name) ]]; then
            continue
        fi
        
        # run module source function if it is declared
        if [[ $(declare -f $module_source_function) ]]; then
            $module_source_function
        fi
    done
}

#--------------------------
## This function iterates over the installed modules list and tryes to run
## modulename_init() function, if it exists.
## Blacklist is checked at each step.
##
## This method should be called *after* module_source().
#--------------------------
function module_init() {    
    local module_init_function=""

    for module_name in ${!module_paths[@]}; do
                
        # blacklist check
        if [[ $(module_blacklist_check $module_name) ]]; then
            continue
        fi

        module_init_function="${module_name}_init"

        if [[ $(declare -f $module_init_function) ]]; then
            $module_init_function
        fi

    done
}

#--------------------------
## This function will output "Yes" if the first parameter it is called with
## is in the blacklist array.
## It will keep quiet (not output anything) it the first parameter is not
## in the blacklist array.
##
## Modules should not use $module_blacklist directly and should use this
## function to ensure that a module is blacklisted or not.
##
## Example usage:
##
##     if [[ $(module_blacklist_check yourmodule) ]]; then
##         echo "yourmodule is blacklisted"
##     else
##         echo "yourmodule is not blacklisted"
##     fi
##
## @Param   Module name
#--------------------------
function module_blacklist_check() {
    for module_name in $module_blacklist; do
        if [[ $module_name == $1 ]]; then
            echo "Yes"
            return -1
        fi
    done

    return 0
}

#--------------------------
## This function adds the first parameter to the blacklist.
##
## User modules should not use the $module_blacklist array dirrectly and
## should add modules to the blacklist through this function.
##
## User modules that do sanity checks should call this function if they
## cannot prepare to be useable.
##
## Example usage:
##
##    # add yourmodule to the blacklist
##    module_blacklist_add yourmodule
#--------------------------
function module_blacklist_add() {
    module_blacklist+=("$1")
}

#--------------------------
## This function takes a module name as first parameter and outputs its
## absolute path.
##
## It provides a reliable way for a script in your module to know its own
## location on the file system.
##
## It is useful to allow a module to be divided in submodules, it allows
## yourmodule_source() to source submodules.
## 
## @Param   Module name
#--------------------------
function module_get_path() {
    echo ${module_paths[$1]}
}

#--------------------------
## This function dumps all module variables.
#--------------------------
function module_debug() {
    echo "For MODULES_PATH: $MODULES_PATH"

    echo "List of loaded modules and paths:"

    for module_name in ${!module_paths[@]}; do
        echo " - ${module_name} from ${module_paths[$module_name]}"
    done

    echo "List of blacklisted modules:"

    for module_name in ${!module_paths[@]}; do
        echo " - ${module_name}"
    done
}

# {{{ Printing functions
# @Credit prince_jammys#bash@irc.freenode.net
# @Credit SourceMage GNU/Linux for bashdoc and the print_ functions
GOOD=$'\e[32;01m'
WARN=$'\e[33;01m'
BAD=$'\e[31;01m'
NORMAL=$'\e[0m'

#--------------------------
##	Output error message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
print_error () {
	echo -e " ${BAD}*${NORMAL} ${FUNCNAME[1]}(): $*" >&2
}
#--------------------------
##	Output warning message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
print_warn () {
	echo -e " ${WARN}*${NORMAL} ${FUNCNAME[1]}(): $*" >&2
}
#--------------------------
##	Output info message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
print_info () {
	echo -e " ${GOOD}*${NORMAL} ${FUNCNAME[1]}(): $*" >&2
}
#--------------------------
##	Output debug message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
print_debug () {
    if [[ -n $jpic_debug ]]; then
        echo -e "   $*" >&2
    fi
}
# }}}

module_source
module_init
