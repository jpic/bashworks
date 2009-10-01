#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Persistent configuration handler module.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
##
## This module is reponsible for management of configuration data of
## other modules.
##
## It currently stores non-array variables in a flatfile given a path, and 
## is able to load it as well.
##
## As a matter of fact, it provides a function allowing the user to configure
## a module interactively.
## 
## See conf/functions.sh for more details on avalaible functions.
#--------------------------

#--------------------------
## Module source callback.
##
## This function should be called when the module is loaded. It will
## load the functions submodule.
#--------------------------
function conf_source() {
    source $(module_get_path conf)/functions.sh
    source $(module_get_path conf)/module.sh
}
