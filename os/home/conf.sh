#!/bin/bash
# -*- coding: utf-8 -*-
# Makes conf load to call os_home_symlink().

# Call os_home_symlink().
function os_home_conf_load() {
    os_home_symlink
    conf_load os_home
}
