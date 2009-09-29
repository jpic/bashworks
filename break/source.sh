#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Break management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
## This module is ideal when you can't manage your hackers: let the GOD BASH
## do it.
#--------------------------

#--------------------------
## Declares module configuration variable names.
## <ul>
## <li>interval: int seconds required between breaks</li>
## </ul>
#--------------------------
function break_init() {
    unset break_variables
    break_variables+=("interval")
    break_variables+=("previous")
    # prefix variable names
    break_variables=("${break_variables[@]/#/break_}")
}

#--------------------------
## Sets the default break interval to 7200 and conf path to ~/.break
#--------------------------
function break_defaults_setter() {
    break_interval=7200
    break_conf_path=${HOME}/.break
}

#--------------------------
## Save your break configuration
#--------------------------
function break_save() {
    conf_save break
}

#--------------------------
## Load your break configuration
#--------------------------
function break_load() {
    conf_load break
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
    break_save
}
