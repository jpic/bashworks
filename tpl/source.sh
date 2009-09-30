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
    source $(module_get_path tpl)/functions.sh
    source $(module_get_path tpl)/conf.sh
}

function tpl() {
    local usage="tpl /path/to/source /path/to/destination"
    tpl_src_path="$1"
    tpl_dest_path="$2"

    if [[ -f $tpl_src_path/source.sh ]]; then
        source $tpl_src_path/source.sh
    fi

    if [[ ! -f $tpl_dest_path/.tpl.sh ]]; then
        tpl_conf_save
    else
        tpl_conf_load
    fi

    cd $tpl_dest_path
}
