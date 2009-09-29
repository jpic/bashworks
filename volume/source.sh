#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Sound volume management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Declares module configuration variable names.
#--------------------------
function volume_source() {
    unset volume_variables
    volume_variables+=("interval")
    volume_variables+=("current")
    # prefix variable names
    volume_variables=("${volume_variables[@]/#/volume_}")

    jpic_module_source volume functions.sh
    jpic_module_source volume conf.sh

    volume_defaults_setter
}

#--------------------------
## Sets the default volume interval to 7200 and conf path to ~/.volume
#--------------------------
function volume_defaults_setter() {
    volume_interval=5
    volume_current=$(volume_get_current)
    volume_conf_path=${HOME}/.volume
}

#--------------------------
## Load configuration on init
#--------------------------
function volume_init() {
    volume_conf_load
}
