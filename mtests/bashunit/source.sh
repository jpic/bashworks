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
## Sources mtest addons for bashunit.
#--------------------------
function mtests_bashunit_source() {
    source $(module_get_path mtests_bashunit)/runner.sh
    source $(module_get_path mtests_bashunit)/assertions.sh
}

#--------------------------
## Sets up environment variables required by bashunit:
## - outputters,
## - listeners
##
## Read bashunit/runner.sh for more information.
#--------------------------
function mtests_bashunit_post_source() {
    if test -z "$BASHUNIT_OUTPUTTER"; then
	    BASHUNIT_OUTPUTTER="TextOutputter"
    fi

    if test -z "$BASHUNIT_TESTLISTENERS"; then
	    BASHUNIT_TESTLISTENERS="TextDotListener ResultCollector";
    fi
}

#--------------------------
## Runs bashunit tests of a module.
#--------------------------
function mtests_bashunit() {
    local bashunit_dir=$(module_get_path mtests)/bashunit/current
    local module_name=$1
    local module_path=$(module_get_path $module_name)

    if [[ ! -d $module_path/bashunit ]]; then
        return 1
    fi

    if [[ -f $module_path/bashunit/tests.sh ]]; then
        source $module_path/bashunit/tests.sh
    fi

    source $bashunit_dir/bashunit_impl $bashunit_dir/resultcollector $module_path/bashunit/*.sh

    ResultCollector Init
    if test -z "$testCase"; then
    	RunAll
    else
    	Run $testCase
    fi
    
    echo
    $BASHUNIT_OUTPUTTER
}
