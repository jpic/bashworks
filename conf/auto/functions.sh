#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Function conf_auto_get_modules() outputs the list of module which the user
# choosed to auto save and load. Its interface is not subject to changes
# although it currently contains a hack to workaround conf module not
# supporting arrays.
# Function conf_auto_load_decorator() decorates conf_load() and so takes a
# module name as argument. This function can be called in your module
# _post_source() function.
# Function conf_auto_save_all calls() conf_save() for all modules which the
# user choosed to auto save and load.

# Output a list of module names which the user choosed to use with this module. 
# Its interface is not subject to changes although it currently contains a hack
# to workaround conf module not supporting arrays.
# The so-called hack is that it uses variables like $conf_auto_yourmodule
# instead of an array of module names.
function conf_auto_get_modules() {
    local variable=""
    local output=""

    for module_name in ${!module_paths[@]}; do
        variable="conf_auto_${module_name}"

        if [[ "${!variable}" == "y" ]]; then
            output+="$module_name "
        fi
    done

    echo $output
}

# Save configuration of each module which the users choosed to use with
# conf_auto().
# @calls   conf_auto_get_modules(), conf_save()
function conf_auto_save_all() {
    for module_name in $(conf_auto_get_modules); do
        conf_save $module_name
    done
}

# Load configuration of each module which the users choosed to use with
# conf_auto().
# @calls   conf_auto_get_modules(), conf_load()
function conf_auto_load_all() {
    for module_name in $(conf_auto_get_modules); do
        conf_load $module_name
    done
}

# Save the configuration of a given module only if the user choosed to use
# it with conf_auto.
# @calls   conf_auto_get_modules(), conf_save()
function conf_auto_save_decorator() {
    local module_name="$1"

    if [[ "$(conf_auto_get_modules)" =~ "$module_name" ]]; then
        conf_save $module_name
    fi
}

# Loads the configuration of a given module only if the user choosed to use
# it with conf_auto.
# @calls   conf_auto_get_modules(), conf_load()
function conf_auto_load_decorator() {
    local module_name="$1"

    if [[ "$(conf_auto_get_modules)" =~ "$module_name" ]]; then
        conf_load $module_name
    fi
}
