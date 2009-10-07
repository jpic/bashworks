#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# This simple module handles making a remote http connection to mpd stream and
# to mpd administration.
# 
# Basically it presents some configurable shortcuts, if you like mpd, mplayer,
# ncmpc and screen then maybe this module will be useful to you.

# Declares module configuration variable names.
function mpd_load() {
    source $(module_get_path mpd)/functions.sh
}

# It sets some defaults and load the user configuration data.
function mpd_post_load() {
    mpd_host=""
    mpd_port=""
    mpd_password=""
    mpd_player=mplayer
    mpd_client=ncmpc
    mpd_screenrc=${HOME}/include/shell/mpd/etc/screenrc
    mpd_url=""
    mpd_conf_path=${HOME}/.mpd

    conf_auto_load_decorator mpd
}
