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
    source $(module_get_path vcs)/functions.sh
    source $(module_get_path vcs)/conf.sh
    source $(module_get_path vcs)/aliases.sh
}

#--------------------------
## Initialises the vcs module in a given sources path.
## @param Path to sources root
#--------------------------
function vcs() {
    local usage="vcs /path/to/sources"
    vcs_src_path="$1"

    if [[ -z $vcs_src_path ]]; then
        print_error "Usage: $usage"
        return 2
    fi

    if [[ ! -f $vcs_src_path/.vcs.sh ]]; then
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
                source $(module_get_path vcs)/${vcs_type}.sh
            fi
        done
    fi
}
