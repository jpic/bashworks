#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Mpd management functions
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Start music player
#--------------------------
function mpd_play() {
    while true;
        do mplayer $mpd_url
    done
}

#--------------------------
## Start remote control
#--------------------------
function mpd_control() {
    ncmpc --host=$mpd_host --password=$mpd_password --port=$mpd_port
}

#--------------------------
## Start or reattach screen
#--------------------------
function mpd_screen() {
    screen -S music -c $mpd_screenrc -D -R
}
