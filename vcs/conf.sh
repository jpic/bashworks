#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Save your vcs configuration
#--------------------------
function vcs_conf_save() {
    conf_save vcs
}

#--------------------------
## Load your vcs configuration
## @param Project name
#--------------------------
function vcs_conf_load() {
    conf_load vcs
}

#--------------------------
## Set the configuration path relative to the sources path
#--------------------------
function vcs_conf_path_setter() {
    vcs_conf_path="${vcs_src_path}/.vcs.sh"
}

#--------------------------
## Interactive module configuration
#--------------------------
function vcs_conf_interactive() {
    conf_interactive vcs
}

