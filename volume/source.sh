#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#	@Synopsis	Sound volume management module
#	@Copyright	Copyright 2009, James Pic
#	@License	Apache
#
# This module provides a simple way to deal with volume management
# under both bsd and linux systems.
#
# Volume incrementation and decrementation interval is saveable as well
# as current volume.
#
# This can easely be used in scripts which your favourite window manager
# can call.

# Module source callback
#
# This function should be called when the module is loaded, it will
# take care of loading the conf and function submodules.
function volume_source() {
    source $(module_get_path volume)/functions.sh
}

# Module initialization callback.
#
# This function is responsible of preparing the module in a useable state
# by setting a default volume interval and getting the current volume.
#
# It also attemps to load the user conf.
function volume_post_source() {
    volume_interval=5
    volume_current=$(volume_get_current)
    volume_conf_path=${HOME}/.volume

    conf_auto_load_decorator volume
}
