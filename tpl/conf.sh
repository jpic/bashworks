#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Save your tpl configuration
#--------------------------
function tpl_conf_save() {
    conf_save tpl
}

#--------------------------
## Load your tpl configuration
## @param Project name
#--------------------------
function tpl_conf_load() {
    conf_load tpl
}

#--------------------------
## Set the configuration path relative to the sources path
#--------------------------
function tpl_conf_path_setter() {
    tpl_conf_path="${tpl_dest_path}/.tpl.${tpl_type}.sh"
}

#--------------------------
## Interactive module configuration
#--------------------------
function tpl_conf_interactive() {
    conf_interactive tpl
}

