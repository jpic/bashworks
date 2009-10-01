#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
## This module wraps around bashunit and shunit frameworks.
#--------------------------

function mtest_source() {
    source $(module_get_path mtest)/bashunit/source.sh
    mtest_bashunit_source

    source $(module_get_path mtest)/shunit/source.sh
    mtest_shunit_source
}

    if [[ -d $module_path/shunit ]]; then
        mtest_shunit $module_name
    fi

    if [[ -d $module_path/shunit2 ]]; then
        mtest_shunit2 $module_name
    fi
}
