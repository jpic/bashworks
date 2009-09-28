#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Bash framework.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
##  Functions to help bash module development.
#--------------------------

# Check bash version. We need at least 3.2.x {{{
# Lets not use anything like =~ here because
# that may not work on old bash versions.
if [[ "$(awk -F. '{print $1 $2}' <<< $BASH_VERSION)" -lt 32 ]]; then
	echo "Sorry your bash version is too old!"
	echo "You need at least version 3.2 of bash"
	echo "Please install a newer version:"
	echo " * Either use your distro's packages"
	echo " * Or see http://www.gnu.org/software/bash/"
	exit 2
fi
# }}}

#--------------------------
## Initialises the framework.
#--------------------------
function jpic_init() {
    jpic_init_configure
    jpic_init_clean_modules
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
function jpic_init_configure() {
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
## Resets paths to modules and variables from modules.
#-------------------------- 
function jpic_init_clean_modules() {
    if [[ $jpic_module_paths != "" ]]; then
        unset jpic_module_paths
        declare -A jpic_module_paths
    fi

    if [[ $jpic_module_variables != "" ]]; then
        unset jpic_module_variables
        declare -A jpic_module_variables
    fi
}

#-------------------------- 
## Finds and fires modules in the modules path.
#-------------------------- 
function jpic_init_modules() {
    for module_path in $JPIC_MODULES_PATH/*; do
        local module_name="${module_path##*/}"
        local module_config_path="$module_path/config.sh"
        
        # source the module
        if [[ -f $module_config_path ]]; then
            source $module_config_path
            
            # append to found modules
            jpic_module_paths[$model_name]=$module_path

            jpic_print_info "Loaded module $module_name from $module_path"
        fi
    done
}

#-------------------------- 
## <p>Saves variables of a module in a file in a loadable format.</p>
## <p>
## If the module configuration path param was not specified then it will try to
## to use $yourmodule_config_path <b>after</b> trying to call
## yourmodule_config_path_setter(), which could set $yourmodule_config_path.
## </p><p>
## Note that it will automatically try to create missing directories and inform
## the user.
## </p>
## @param Module name
## @param Module configuration path (optionnal)
## @return 2 If it could not save the module variables into a config file.
#-------------------------- 
function jpic_module_save() {
    local usage="jpic_module_save \$module_name [\$module_config_path]"
    local module_name="$1"
    local module_config_path="$2"
    # config path variable callback
    local module_config_path_setter="${module_name}_set_config_path"
    # config path variable
    local module_config_path_varname="${module_name}_config_path"
    # module variables array
    local module_variables="${module_name}_variables[@]"

    if [[ $module_name == "" ]]; then
        echo "$usage"
        return 2
    fi

    # if $2 was not specified
    # and ${module_name}_set_config_path is a function
    if [[ -n $module_config_path ]] && [[ $(declare -f $module_config_path_setter) ]]; then
        # run the function
        $module_config_path_setter
    # elif $2 was not specified
    # and ${module_name}_config_path is not a non-zero variable
    elif [[ -z $module_config_path ]] && [[ -n ${!module_config_path_varname} ]]; then
        # use that variable
        module_config_path="${!module_config_path_varname}"
    else # die
        jpic_print_error "Died: could not figure ${module_name} config path"
        return 2
    fi

    if [[ ! -f $module_config_path ]]; then
        # make required directories
        local directory=${module_config_path%/*}
        mkdir -p $directory
        jpic_print_info "Created $directory for $module_config_path"
        touch $module_config_path
    fi

    for variable in ${!module_variables}; do
        local value="${!variable}"

        grep -q "^${variable}=\"[^\"]*\"$" $module_config_path

        if [[ $? -eq 0 ]]; then
            sed -i -e "s@${variable}=.*@${variable}=\"$value\"@" $module_config_path
        else
            echo "${variable}=\"${value}\"" >> $module_config_path
        fi
    done
}

# {{{ Printing functions
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
	echo -e " ${BAD}*${NORMAL} $*" >&2
}
#--------------------------
##	Output warning message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
jpic_print_warn () {
	echo -e " ${WARN}*${NORMAL} $*" >&2
}
#--------------------------
##	Output info message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
jpic_print_info () {
	echo -e " ${GOOD}*${NORMAL} $*" >&2
}
#--------------------------
##	Output debug message
##	@param	Message
##	@Stderr	Formated message
#--------------------------
jpic_print_debug () {
    echo -e "   $*" >&2
}
# }}}

jpic_init
