#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Mpd management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
##
## This simple module handles making a remote http connection to mpd stream
## and to mpd administration.
## 
## Basically it presents some configurable shortcuts
#--------------------------

#--------------------------
## Declares module configuration variable names.
#--------------------------
function mpd_source() {
    source $(module_get_path mpd)/functions.sh
    source $(module_get_path mpd)/conf.sh
}

#--------------------------
## Module initialization callback
##
## This function is responsible for putting the module in a useable state.
##
## It sets some defaults and load the user configuration data.
#--------------------------
function mpd_post_source() {
    mpd_player=mplayer
    mpd_client=ncmpc
    mpd_screenrc=${HOME}/include/shell/mpd/etc/screenrc
    mpd_conf_path=${HOME}/.mpd

    mpd_conf_load
}
