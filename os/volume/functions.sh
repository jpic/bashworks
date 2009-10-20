#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Volume management functions which are good to use to make window manager
# bindings.
# Supports "mixer" from FreeBSD and "amixer" from Linux/Alsa.

# Outputs the current volume
function os_volume_get_current() {
    if command -v mixer > /dev/null; then
        mixer vol | grep -o ':[0-9]*' | cut -c 2-5
    else
        # TODO? implement Linux support? But linux has mute support so ...
        mlog error "Command mixer not available"
    fi
}

# Increase volume with $os_volume_interval
function os_volume_inc() {
    if command -v mixer > /dev/null; then
        mixer vol +$os_volume_interval
    elif command -v amixer > /dev/null; then
        amixer -q -c 0 sset Master,0 ${os_volume_interval}dB+
    else
        mlog error "Currently only supporting mixer and amixer commands"
    fi
}

# Decrease volume with $os_volume_interval
function os_volume_dec() {
    if command -v mixer > /dev/null; then
        mixer vol -$os_volume_interval
    elif command -v amixer > /dev/null; then
        amixer -q -c 0 sset Master,0 ${os_volume_interval}dB-
    else
        mlog error "Currently only supporting mixer and amixer commands"
    fi
}

# Unmute
function os_volume_unmute() {
    if command -v mixer > /dev/null; then
        mixer vol $os_volume_current
    elif command -v amixer > /dev/null; then
        amixer -q -c 0 sset Master,0 unmute
    else
        mlog error "Currently only supporting mixer and amixer commands"
    fi
}


# Mute
function os_volume_mute() {
    conf_save os_volume

    if command -v mixer > /dev/null; then
        mixer vol 0
    elif command -v amixer > /dev/null; then
        amixer -q -c 0 sset Master,0 mute
    else
        mlog error "Currently only supporting mixer and amixer commands"
    fi
}
