#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
## Wraps around shunit2 bash testing framework. Read shunit2/current/README for
## information about working with shunit2.
## <p>
## Module tests which use shunit2 should be in a subdirectory of the module
## named "shunit2".
#--------------------------

#--------------------------
## Runs the shunit2 test suite of a given module.
## @polite  Will try yourmodule_mtests_shunit2()
#--------------------------
function mtests_shunit2() {
    local module_name="$1"
    local module_path="$(module_get_path $module_name)"

    # politeness snippet
    local module_overload="${module_name}_mtests_shunit2"
    if [[ $(declare -f $module_overload) ]]; then
        if [[ ! ${FUNCNAME[*]} =~ $module_overload ]]; then
            $module_overload
            return $?
        fi
    fi

    if [[ ! -d "$module_path/shunit2" ]]; then
        return 1
    fi

    source "$module_path"/shunit2/*.sh

    source "$(module_get_path mtests_shunit2)/current/src/shell/shunit2"
}
