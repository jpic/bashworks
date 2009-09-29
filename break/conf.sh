#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management configuration module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Save your break configuration
#--------------------------
function break_conf_save() {
    conf_save break
}

#--------------------------
## Load your break configuration
#--------------------------
function break_conf_load() {
    conf_load break
}
