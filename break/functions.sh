#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management module functions
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache

#--------------------------
## Sets the default break interval to 7200 and conf path to ~/.break
#--------------------------
function break_defaults_setter() {
    break_interval=7200
    break_conf_path=${HOME}/.break
}

#--------------------------
## Is your break granted?
#--------------------------
function break_request() {
    if [[ -z $break_previous ]]; then
        echo "Granted, enjoy"
        break_do
    elif [[ $(( $(date +%s) - $break_previous )) < $break_interval ]]; then
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
    break_conf_save
}
