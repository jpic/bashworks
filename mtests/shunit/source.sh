#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Wraps around shunit bash testing framework. Read shunit/current/README for
# information about working with shunit.
# Module tests which use shunit should be in a subdirectory of the module
# named "shunit".

# Sets $SHUNIT_HOME environment variable required by shunit.
function mtests_shunit_pre_load() {
    export SHUNIT_HOME="$(module_get_path mtests_shunit)/current"
}

# Loads shUnitPlus.
function mtests_shunit_load() {
    source "$(module_get_path mtests_shunit)"/current/shUnitPlus >/dev/null 2>&1
}

# Runs the test suites of a module.
# @polite  Will try yourmodule_mtests_shunit()
# @calls   shuStart()
function mtests_shunit() {
    local module_name=$1

    local module_overload="${module_name}_mtests_shunit"

    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    local module_path="$(module_get_path $module_name)"

    if [[ ! -d $module_path/shunit ]]; then
        return 1
    fi

    if [[ -f $module_path/shunit.sh ]]; then
        source $module_path/shunit.sh
    fi

    source $module_path/shunit/*.sh

    shuStart
}
