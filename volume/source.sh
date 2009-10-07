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
function volume_load() {
    source $(module_get_path volume)/functions.sh
}

# This function is responsible of preparing the module in a useable state
# by setting a default volume interval and getting the current volume.
function volume_post_load() {
    volume_interval=5
    volume_current=$(volume_get_current)
    volume_conf_path=${HOME}/.volume
}
