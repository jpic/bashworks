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
function break_source() {
    unset break_variables
    break_variables+=("interval")
    break_variables+=("previous")
    # prefix variable names
    break_variables=("${break_variables[@]/#/break_}")


    jpic_module_source break functions.sh
    jpic_module_source break conf.sh

    break_defaults_setter
}

#--------------------------
## Sets the default break interval to 7200 and conf path to ~/.break
#--------------------------
function break_defaults_setter() {
    break_interval=7200
    break_conf_path=${HOME}/.break
}
