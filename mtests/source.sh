#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# This module wraps around xUnit frameworks through submodules:
# - bashunit: tested, working in module break,
# - shunit: untested, should work
# - shunit2: untested, recommanded

# Runs all tests of a given module.
# <p>
# If the module has a "bashunit" sub directory then mtests_bashunit will be
# called. Same goes for the other supported test frameworks: "shunit" and
# "shunit2",
# <p>
# Shunit2 is recommanded.
# @polite  Will try yourmodule_mtests()
# @calls   mtests_bashunit, mtests_shunit, mtests_shunit2
function mtests() {
    local module_name="$1"
    local module_path="$(module_get_path $module_name)"
    local module_test_function="${module_name}_mtests"

    if [[ $(declare -f $module_test_function) ]]; then
        $module_test_function
        return 0
    fi
    
    if [[ -d $module_path/bashunit ]]; then
        mtests_bashunit $module_name
    fi

    if [[ -d $module_path/shunit ]]; then
        mtests_shunit $module_name
    fi

    if [[ -d $module_path/shunit2 ]]; then
        mtests_shunit2 $module_name
    fi
}
