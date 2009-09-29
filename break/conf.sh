#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

unset break_variables
break_variables+=("interval")
break_variables+=("previous")
# prefix variable names
break_variables=("${break_variables[@]/#/break_}")

#--------------------------
## Save your break configuration
#--------------------------
function break_conf_save() {
    conf_save $break_conf_path $break_variables
}

#--------------------------
## Load your break configuration
#--------------------------
function break_conf_load() {
    conf_save $break_conf_path
}

#--------------------------
## Interactive module configuration
#--------------------------
function break_conf_interactive() {
    conf_interactive $break_variables
    break_conf_save
}
