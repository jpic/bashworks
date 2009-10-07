#!/bin/bash
# -*- coding: utf-8 -*-
# This module provides an abstraction layer to the current OS package manager,
# be it emerge, bsd ports ...

function os_pkg_source() {
    if [[ -n `which emerge` ]]; then
        source $(module_get_path os_pkg)/gentoo.sh
    elif [[ -d /usr/ports ]]; then
        source $(module_get_path os_pkg)/bsd.sh
    fi
}
