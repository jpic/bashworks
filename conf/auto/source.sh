#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# This submodule of conf allows the user to define the modules which config
# should be auto saved and auto loaded.
# It is the only module which _post_load() function, conf_auto_post_load()
# should call conf_load() because other module should have their configuration
# loaded by conf_auto_load_all().
# See conf_auto/functions.sh for information about the additionnal API for
# conf.
# See conf_auto/conf.sh for information about the conf overloads for this
# module.

# Loads the functions that extend the conf API and the conf overloads.
function conf_auto_load() {
    source $(module_get_path conf_auto)/functions.sh
    source $(module_get_path conf_auto)/conf.sh
}

# Sets conf_auto_conf_path and loads the module configuration.
# Note: your modules should not call conf_load in their _post_load() func, it
# should call conf_auto_load_decorator() instead, see functions.sh for more
# details.
# @calls conf_load()
function conf_auto_post_load() {
    conf_auto_conf_path="$HOME/.conf_auto"

    conf_load conf_auto
}
