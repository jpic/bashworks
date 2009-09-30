#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

unset tpl_variables
tpl_variables+=("type")
tpl_variables+=("dest_path")
tpl_variables+=("src_path")
# prefix variable names
tpl_variables=("${tpl_variables[@]/#/tpl_}")

#--------------------------
## Save your tpl configuration
#--------------------------
function tpl_conf_save() {
    conf_save ${tpl_dest_path}/.tpl.sh $tpl_variables
}

#--------------------------
## Load your tpl configuration
## @param Project name
#--------------------------
function tpl_conf_load() {
    conf_load ${tpl_dest_path}/.tpl.sh
}

#--------------------------
## Interactive module configuration
#--------------------------
function tpl_conf_interactive() {
    conf_interactive $tpl_variables
}

