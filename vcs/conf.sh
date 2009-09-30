#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

unset vcs_variables
vcs_variables+=("src_path")
vcs_variables+=("type")
# prefix variable names
vcs_variables=("${vcs_variables[@]/#/vcs_}")

#--------------------------
## Save your vcs configuration to the current source path in file .vcs.sh
#--------------------------
function vcs_conf_save() {
    conf_save $vcs_src_path/.vcs.sh $vcs_variables
}

#--------------------------
## Load your vcs configuration
## @param Project name
#--------------------------
function vcs_conf_load() {
    conf_load $vcs_src_path/.vcs.sh $vcs_variables
}

#--------------------------
## Interactive module configuration
#--------------------------
function vcs_conf_interactive() {
    conf_interactive $vcs_variables
    vcs_conf_save
}

