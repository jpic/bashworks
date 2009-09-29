#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
## This module is ideal when you can't manage your hackers: let the GOD BASH
## do it.
#--------------------------

#--------------------------
## Declares module configuration variable names.
#--------------------------
function tpl_source() {
    unset tpl_variables
    tpl_variables+=("type")
    tpl_variables+=("dest_path")
    tpl_variables+=("src_path")
    # prefix variable names
    tpl_variables=("${tpl_variables[@]/#/tpl_}")

    jpic_module_source tpl functions.sh
    jpic_module_source tpl conf.sh

    tpl_defaults_setter
}

#--------------------------
## Sets the default tpl interval to 7200 and conf path to ~/.tpl
#--------------------------
function tpl_defaults_setter() {
    tpl_src_path="$(jpic_module_path tpl)/${tpl_type}"
}

function tpl() {
    local usage="tpl type /path/to/destination"
    tpl_type="$1"
    tpl_dest_path="$2"

    if [[ -z $tpl_type ]] || [[ -z $tpl_dest_path ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    tpl_conf_path_setter

    if [[ ! -f $tpl_conf_path ]]; then
        tpl_conf_save
    else
        tpl_conf_load
    fi

    cd $tpl_dest_path

    # jpic_module_source tpl $tpl_type
}
