#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Declares module configuration variable names.
#--------------------------
function vcs_source() {
    unset vcs_variables
    vcs_variables+=("src_path")
    vcs_variables+=("type")
    # prefix variable names
    vcs_variables=("${vcs_variables[@]/#/vcs_}")

    jpic_module_source vcs functions.sh
    jpic_module_source vcs conf.sh
    jpic_module_source vcs aliases.sh

    vcs_defaults_setter
}

#--------------------------
## Sets the default vcs interval to 7200 and conf path to ~/.vcs
#--------------------------
function vcs_defaults_setter() {
    return
}

#--------------------------
## Initialises the vcs module in a given sources path.
## @param Path to sources root
#--------------------------
function vcs() {
    local usage="vcs /path/to/sources"
    vcs_src_path="$1"

    if [[ -z $vcs_src_path ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    vcs_conf_path_setter

    if [[ ! -f $vcs_conf_path ]]; then
        vcs_conf_save
    else
        vcs_conf_load
    fi

    cd $vcs_src_path

    if [[ -z $vcs_type ]]; then
        for vcs_type in git hg svn; do
            print_debug "Checking for $vcs_type in $vcs_src_path"
            if [[ -d ".$vcs_type" ]]; then
                print_debug "Found $vcs_type in $vcs_src_path"
                jpic_module_source vcs "${vcs_type}.sh"
            fi
        done
    fi
}
