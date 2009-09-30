#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

unset vps_variables
vps_variables+=("name")
vps_variables+=("root")
vps_variables+=("id")
vps_variables+=("packages_dir")
vps_variables+=("master")
vps_variables+=("mailer")
vps_variables+=("stage_name")
vps_variables+=("stage_url")
vps_variables+=("admin")
vps_variables+=("ip")
vps_variables+=("host_ip")
# prefix variable names
vps_variables=("${vps_variables[@]/#/vps_}")

#--------------------------
## Save your vps configuration
#--------------------------
function vps_conf_save() {
    conf_save $VPS_ETC_DIR/${vps_name}.config $vps_variables
}

#--------------------------
## Load your vps configuration
## @param Project name
#--------------------------
function vps_conf_load() {
    conf_load $VPS_ETC_DIR/${vps_name}.config
}

#--------------------------
## Interactive module configuration
#--------------------------
function vps_conf_interactive() {
    conf_interactive $vps_variables
}
