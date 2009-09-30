#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Mpd management conf
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

unset mpd_variables
mpd_variables+=("host")
mpd_variables+=("port")
mpd_variables+=("password")
mpd_variables+=("client")
mpd_variables+=("player")
mpd_variables+=("screenrc")
mpd_variables+=("url")
# prefix variable names
mpd_variables=("${mpd_variables[@]/#/mpd_}")

#--------------------------
## Save your mpd configuration
#--------------------------
function mpd_conf_save() {
    conf_save $mpd_conf_path $mpd_variables
}

#--------------------------
## Load your mpd configuration
#--------------------------
function mpd_conf_load() {
    conf_save $mpd_conf_path
}

#--------------------------
## Interactive module configuration
#--------------------------
function mpd_conf_interactive() {
    conf_interactive $mpd_variables
    mpd_conf_save
}
