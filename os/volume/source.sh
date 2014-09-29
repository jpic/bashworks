#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# This module provides a simple way to deal with volume management under both
# bsd and linux systems.
# Volume incrementation and decrementation interval is saveable as well as
# current volume.
# This can easely be used in scripts which your favourite window manager can
# call.

# This function should be called when the module is loaded, it will
# take care of loading the conf and function submodules.
function os_volume_load() {
    source "$(module_get_path os_volume)"/functions.sh
}

# This function is responsible of preparing the module in a useable state
# by setting a default volume interval and getting the current volume.
function os_volume_post_load() {
    os_volume_interval=5
    os_volume_current=$(os_volume_get_current)
    os_volume_conf_path=${HOME}/.volume
}
