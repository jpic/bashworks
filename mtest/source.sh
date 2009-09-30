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

function mtest_init() {
    mtest_bashunit_init
    mtest_shunit_init
}

function mtest() {
    mtest_bashunit $*
    mtest_shunit_init $*
}
