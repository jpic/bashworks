#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#	@Synopsis	Mpd management functions
#	@Copyright	Copyright 2009, James Pic
#	@License	Apache

# This starts or reattach a screen session with both the player and the
# remote controll in its windows.
function mpd_screen() {
    screen -S music -c $mpd_screenrc -D -R
}

# Starts your player command in a loop.
#
# Press Ctrl+C a few times to stop it.
function mpd_play() {
    while true;
        do $mpd_player $mpd_url
    done
}

# Starts ncmpc to remote controll mpd.
function mpd_control() {
    ncmpc --host=$mpd_host --password=$mpd_password --port=$mpd_port
}
