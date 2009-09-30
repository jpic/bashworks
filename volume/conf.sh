#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Sound volume management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

unset volume_variables
volume_variables+=("interval")
volume_variables+=("current")
# prefix variable names
volume_variables=("${volume_variables[@]/#/volume_}")

#--------------------------
## Saves the current volume and interval
#--------------------------
function volume_conf_save() {
    volume_current=$(volume_get_current)

    conf_save $volume_conf_path $volume_variables
}

#--------------------------
## Load your volume configuration
#--------------------------
function volume_conf_load() {
    conf_load $volume_conf_path
}

#--------------------------
## Interactive module configuration
#--------------------------
function volume_conf_interactive() {
    conf_interactive $volume_variables
    volume_conf_save
}
