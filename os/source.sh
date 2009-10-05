#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#	@Synopsis	OS management module
#	@Copyright	Copyright 2009, James Pic
#	@License	Apache
#  In its early version, it just figures the os.
#  The plan: port multi-os compiles and bin/ symlinks from my .bashrc

# Declares module configuration variable names and sets the os.
function os_source() {
    uname -a | grep -q -i bsd
    if [[ $? -eq 0 ]]; then
        os_type=bsd
    else
        os_type=linux
    fi
}
