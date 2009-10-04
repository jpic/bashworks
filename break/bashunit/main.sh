#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
## This file declares functions to test the break module which are useable
## with the mtests_bashunit submodule.
#-------------------------- 

#-------------------------- 
## Sets up an arbitary conf path and break interval for testing.
## @calls   break_post_source()
#-------------------------- 
function Setup() {
    break_post_source
    
    break_conf_path=/tmp/break.test
    break_interval=3

    if [[ -f $break_conf_path ]]; then
        rm -rf $break_conf_path
    fi
}

#-------------------------- 
## Removes the temporary break configuration file.
#-------------------------- 
function Teardown() {
    rm -rf $break_conf_path
}

#-------------------------- 
## Asserts that break_do() updates $break_previous.
## @call    break_do(), assert_math()
#-------------------------- 
function test_break_do_update_break_previous() {
    break_previous=0
    break_do
    assert_math "$break_previous > 0"
}

#-------------------------- 
## Stress break_do() to make sure it updates $break_previous.
## @call    break_do(), assert_math()
#-------------------------- 
function test_break_do_update_break_previous_stress() {
    break_do
    assert_math "$break_previous > 0"
    
    backup="$break_previous"
    sleep 1
    
    break_do
    assert_math "$break_previous > $backup"
}

#-------------------------- 
## Asserts that break_request() will deny if break_do() was just called.
## @call    break_do(), break_request()
#-------------------------- 
function test_denied_break_request() {
    break_do
    
    if ! [[ $(break_request) =~ Denied ]]; then
        # die/fail if routput doesn't contain "Denied"
		kill -USR1 $$
    fi
}
