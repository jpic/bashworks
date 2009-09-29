#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Sound volume management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Declares module configuration variable names.
#--------------------------
function volume_init() {
    unset volume_variables
    volume_variables+=("interval")
    volume_variables+=("current")
    # prefix variable names
    volume_variables=("${volume_variables[@]/#/volume_}")
}

#--------------------------
## Sets the default volume interval to 7200 and conf path to ~/.volume
#--------------------------
function volume_defaults_setter() {
    volume_interval=5
    volume_current=$(volume_get_current)
    volume_conf_path=${HOME}/.volume
}

#--------------------------
## Saves the current volume and interval
#--------------------------
function volume_save() {
     case $os_type in
        bsd)
            volume_current=$(volume_get_current)
            ;;
        linux)
            jpic_print_error TODO: implement Linux support? But linux has mute support so ...
            ;;
    esac

    conf_save volume
}

#--------------------------
## Outputs the current volume
#--------------------------
function volume_get_current() {
     case $os_type in
        bsd)
            mixer vol | grep -o ':[0-9]*' | cut -c 2-5
            ;;
        linux)
            jpic_print_error TODO: implement Linux support? But linux has mute support so ...
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
    volume_save

    case $os_type in
        bsd)
            mixer vol 0
            ;;
        linux)
            amixer -q -c 0 sset Master,0 mute
            ;;
    esac
}
