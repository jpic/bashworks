#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Sound volume management configuration
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Saves the current volume and interval
#--------------------------
function volume_conf_save() {
    volume_current=$(volume_get_current)

    conf_save volume
}

#--------------------------
## Load your volume configuration
#--------------------------
function volume_conf_load() {
    conf_load volume
}

#--------------------------
## Interactive module configuration
#--------------------------
function volume_conf_interactive() {
    conf_interactive volume
}
