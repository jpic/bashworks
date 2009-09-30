#!/bin/bash
function Setup() {
    break_init
    
    break_conf_path=/tmp/break.test
    break_interval=3

    if [[ -f $break_conf_path ]]; then
        rm -rf $break_conf_path
    fi
}

function Teardown() {
    rm -rf $break_conf_path
}

function test_break_do_update_break_previous() {
    break_previous=0
    break_do
    assert_math "$break_previous > 0"
}

function test_break_do_update_break_previous_stress() {
    break_do
    assert_math "$break_previous > 0"
    
    backup="$break_previous"
    sleep 1
    
    break_do
    assert_math "$break_previous > $backup"
}

function test_denied_break_request() {
    break_do
    
    if ! [[ $(break_request) =~ Denied ]]; then
        # die/fail if routput doesn't contain "Denied"
		kill -USR1 $$
    fi
}
