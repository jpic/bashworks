#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
## Bashdoc tiein for the docs module.
#--------------------------

#--------------------------
## Outputs the documentation for a given module to 
## $docs_path/modules/$module_name.
## @param   Module name
#--------------------------
function docs_bashdoc_for_module() {
    local module_name="$1"
    local path="$docs_path/modules/$module_name"
    local module_path="$(module_get_path $module_name)"

    $(module_get_path docs_bashdoc)/current/bashdoc.sh \
        -p $module_name \
        -o $path \
        `find "$module_path" \( -name bashunit -prune \) -o \( -type f -name "*.sh" -print \)`
}
