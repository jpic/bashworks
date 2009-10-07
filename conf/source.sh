#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# This module declares functions to interface with configuration variables and
# files in functions.sh, and functions that take a module as argument in
# module.sh.
# 
# See conf/functions.sh for more details on avalaible functions.
# See conf/module.sh for details concerning functions that work with modules.

# This function should be called when the module is loaded. It will load
# functions it depends on.
function conf_load() {
    source $(module_get_path conf)/functions.sh
    source $(module_get_path conf)/module.sh
}
