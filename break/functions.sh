#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Functions to request or take a break.

# Is your break granted?
# @stdout  Wether your request was granted or denied.
# @calls   break_do()
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

# Take a break. Updates the previous break timestamp and saves for anti-cheat
# security.
# @calls   conf_save()
function break_do() {
    break_previous=$(date +%s)
    conf_save break
}
