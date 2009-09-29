#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Template management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

VPS_DIR="/vservers"
VPS_CONFIG_FILE="vps.sh"

#--------------------------
## Declares module configuration variable names.
#--------------------------
function vps_source() {
    unset vps_variables
    vps_variables+=("name")
    vps_variables+=("root")
    vps_variables+=("id")
    vps_variables+=("foo")
    # prefix variable names
    vps_variables=("${vps_variables[@]/#/vps_}")

    jpic_module_source vps functions.sh
    jpic_module_source vps conf.sh
    jpic_module_source vps aliases.sh

    vps_defaults_setter
}

#--------------------------
## Sets the default vps interval to 7200 and conf path to ~/.vps
#--------------------------
function vps_defaults_setter() {
    vps_id=$(vps_get_free_id)
}

#--------------------------
## Initialises a vps configuration with a given name
## @param VPS name
#--------------------------
function vps() {
    local usage="vps \$vps_name"
    vps_name="$1"

    if [[ -z $vps_name ]]; then
        jpic_print_error "Usage: $usage"
    fi

    vps_root="${VPS_DIR}/${vps_name}"

    vps_conf_path_setter

    if [[ ! -f $vps_conf_path ]]; then
        vps_defaults_setter
        vps_conf_save
    else
        vps_conf_load
    fi
    
    cd $vps_src_path

    if [[ -z $vps_type ]]; then
        for vps_type in git hg svn; do
            jpic_print_debug "Checking for $vps_type in $vps_src_path"
            if [[ -d ".$vps_type" ]]; then
                jpic_print_debug "Found $vps_type in $vps_src_path"
                jpic_module_source vps "${vps_type}.sh"
            fi
        done
    fi
}
