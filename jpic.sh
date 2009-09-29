#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Bash framework.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
##  Functions to help bash module development.
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
	exit 2
fi
# }}}

declare -A jpic_module_paths
declare -A jpic_module_variables

#--------------------------
## Initialises the framework.
#--------------------------
function jpic_init() {
    jpic_debug=1
    jpic_repo_setup
    jpic_source_modules
    jpic_init_modules
}

#--------------------------
## Configures the framework for initialisation of module repository and
## configuration paths.
## <p>
## $JPIC_MODULES_PATH should contain the path to the module repository
## (default: <b>$HOME/include/shell</b>).
## </p><p>
## $JPIC_MODULES_CONFIG_PATH should contain the path to module configuration
## files (default: <b>$HOME/etc</b>).
## </p>
#-------------------------- 
function jpic_repo_setup() {
    # define a default path for "jpic-ish" modules
    if [[ $JPIC_MODULES_PATH == "" ]]; then
        export JPIC_MODULES_PATH="$HOME/include/shell"
    fi
    
    # define a default path for "jpic-ish" module configurations
    if [[ $JPIC_MODULES_CONFIG_PATH == "" ]]; then
        export JPIC_MODULES_CONFIG_PATH="$HOME/etc"
    fi
}

#-------------------------- 
## Finds and fires modules in the modules path.
#-------------------------- 
function jpic_source_modules() {
    for module_path in $JPIC_MODULES_PATH/*; do
        local module_name="${module_path##*/}"
        local module_source_path="${module_path}/source.sh"
        local module_source="${module_name}_source"
        
        # source the module
        if [[ -f $module_source_path ]]; then
            source $module_source_path
            
            # append to found modules
            jpic_module_paths[$module_name]=$module_path

            # attempt to call yourmodule_source()
            if [[ $(declare -f $module_source) ]]; then
                $module_source
            fi

            jpic_print_debug "Sourced $module_name"
        fi
    done
}

#-------------------------- 
## Sources a file from a module directory
## @param Module name
## @param Path to file to source
#-------------------------- 
function jpic_module_source() {
    local usage="example usage: jpic_module_source conf functions.sh"
    local module_name=$1
    local module_source=$2
    local module_dir=${jpic_module_paths[$module_name]}
    local module_source_path=$module_dir/$module_source

    if [[ -z $module_name ]] || [[ -z $module_source ]]; then
        jpic_print_error $usage
        return 2
    fi

    jpic_print_debug "Sourcing submodule: $module_source_path"
    source $module_source_path
}

#-------------------------- 
## Runs yourmodule_init if it exists, for each sourced module.
#-------------------------- 
function jpic_init_modules() {
    for module_name in ${!jpic_module_paths[@]}; do
        local module_init="${module_name}_init"

        if [[ $(declare -f $module_init) ]]; then
            $module_init
        fi

        jpic_print_debug "Initialised $module_name"
    done
}


#-------------------------- 
## Outputs the absolute path to a module.
#-------------------------- 
function jpic_get_module_path() {
    module_name="$1"

    echo ${jpic_module_paths[$module_name]}
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
jpic_print_error () {
	echo -e " ${BAD}*${NORMAL} ${FUNCNAME[1]}(): $*" >&2
}
#--------------------------
##	Output warning message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
jpic_print_warn () {
	echo -e " ${WARN}*${NORMAL} ${FUNCNAME[1]}(): $*" >&2
}
#--------------------------
##	Output info message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
jpic_print_info () {
	echo -e " ${GOOD}*${NORMAL} ${FUNCNAME[1]}(): $*" >&2
}
#--------------------------
##	Output debug message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
jpic_print_debug () {
    if [[ -n $jpic_debug ]]; then
        echo -e "   $*" >&2
    fi
}
# }}}

jpic_init
