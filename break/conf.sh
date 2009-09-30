#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Save your break configuration
#--------------------------
function break_conf_save() {
    conf_save $break_conf_path break_interval break_previous
}

#--------------------------
## Load your break configuration
#--------------------------
function break_conf_load() {
    conf_load $break_conf_path
}

#--------------------------
## Interactive module configuration
#--------------------------
function break_conf_interactive() {
    conf_interactive break_interval
    break_conf_save
}
