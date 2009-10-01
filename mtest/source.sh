#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
## This module wraps around xUnit frameworks:
## - bashunit: tested, working in module break,
## - shunit: untested, should work
## - shunit2: untested
#--------------------------

function mtest() {
    local module_name="$1"
    local module_path="$(module_get_path $1)"
    local module_test_function="${module_name}_test"

    if [[ $(declare -f $module_test_function) ]]; then
        $module_test_function
        return 0
    fi
    
    if [[ -d $module_path/bashunit ]]; then
        mtest_bashunit $module_name
    fi

    if [[ -d $module_path/shunit ]]; then
        mtest_shunit $module_name
    fi

    if [[ -d $module_path/shunit2 ]]; then
        mtest_shunit2 $module_name
    fi
}
