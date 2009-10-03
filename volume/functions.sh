#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Sound volume management functions
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Outputs the current volume
#--------------------------
function volume_get_current() {
     case $os_type in
        bsd)
            mixer vol | grep -o ':[0-9]*' | cut -c 2-5
            ;;
        linux)
            mlog error TODO: implement Linux support? But linux has mute support so ...
            ;;
    esac
}

#--------------------------
## Increase volume with $volume_interval
#--------------------------
function volume_inc() {
    case $os_type in
        bsd)
            mixer vol +$volume_interval
            ;;
        linux)
            amixer -q -c 0 sset Master,0 ${volume_interval}dB+
            ;;
    esac
}

#--------------------------
## Decrease volume with $volume_interval
#--------------------------
function volume_dec() {
    case $os_type in
        bsd)
            mixer vol -$volume_interval
            ;;
        linux)
            amixer -q -c 0 sset Master,0 ${volume_interval}dB-
            ;;
    esac
}

#--------------------------
## Unmute
#--------------------------
function volume_unmute() {
    case $os_type in
        bsd)
            mixer vol $volume_current
            ;;
        linux)
            amixer -q -c 0 sset Master,0 unmute
            ;;
    esac
}


#--------------------------
## Mute
#--------------------------
function volume_mute() {
    volume_conf_save

    case $os_type in
        bsd)
            mixer vol 0
            ;;
        linux)
            amixer -q -c 0 sset Master,0 mute
            ;;
    esac
}
