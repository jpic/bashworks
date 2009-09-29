#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Save your vps configuration
#--------------------------
function vps_conf_save() {
    conf_save vps
}

#--------------------------
## Load your vps configuration
## @param Project name
#--------------------------
function vps_conf_load() {
    conf_load vps
}

#--------------------------
## Set the configuration path relative to the sources path
#--------------------------
function vps_conf_path_setter() {
    vps_conf_path="${vps_root}/vps.sh"
}

#--------------------------
## Interactive module configuration
#--------------------------
function vps_conf_interactive() {
    conf_interactive vps
}

