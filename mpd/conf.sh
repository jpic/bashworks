#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Mpd management conf
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Save your mpd configuration
#--------------------------
function mpd_conf_save() {
    conf_save mpd
}

#--------------------------
## Load your mpd configuration
#--------------------------
function mpd_conf_load() {
    conf_load mpd
}

#--------------------------
## Interactive module configuration
#--------------------------
function mpd_conf_interactive() {
    conf_interactive mpd
}
