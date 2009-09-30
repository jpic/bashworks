#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
## This module wraps around Bashunit. Read mtest/bashunit/README for more
## information about bashunit. 
#--------------------------

#--------------------------
#--------------------------
function mtest_source() {
#    source $(module_get_path mtest)/functions.sh
    source $(module_get_path mtest)/runner.sh
    source $(module_get_path mtest)/assertions.sh
}

#--------------------------
#--------------------------
function mtest_init() {
    if test -z "$BASHUNIT_OUTPUTTER"; then
	    BASHUNIT_OUTPUTTER="TextOutputter"
    fi

    if test -z "$BASHUNIT_TESTLISTENERS"; then
	    BASHUNIT_TESTLISTENERS="TextDotListener ResultCollector";
    fi
}

#--------------------------
#--------------------------
function mtest() {
    local bashunit_dir=$(module_get_path mtest)/bashunit
    local module_name=$1
    local module_path=$(module_get_path $module_name)

    if [[ -f $module_path/tests.sh ]]; then
        source $module_path/tests.sh
    fi

    source $bashunit_dir/bashunit_impl $bashunit_dir/resultcollector $module_path/tests/*.sh

    ResultCollector Init
    if test -z "$testCase"; then
    	RunAll
    else
    	Run $testCase
    fi
    
    echo
    $BASHUNIT_OUTPUTTER
}
