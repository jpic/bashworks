#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management module functions
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache

#--------------------------
## Is your break granted?
#--------------------------
function break_request() {
    if [[ -z $break_previous ]]; then
        echo "Enjoy your first break"
        break_do
        return 0
    fi

    declare now="$(date +%s)"
    actual_interval=$(( $now - $break_previous ))
    
    if (( $actual_interval < $break_interval )); then
        echo "Denied, get back to work."
    else
        echo "Granted, enjoy"
        break_do
    fi
}

#--------------------------
## Updates the previous break timestamp and saves for anti-cheat security.
#--------------------------
function break_do() {
    break_previous=$(date +%s)
    conf_save break
}
