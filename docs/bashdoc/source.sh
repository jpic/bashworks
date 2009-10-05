#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Bashdoc tiein for the docs module.

# Outputs the documentation for a given module to 
# $docs_path/modules/$module_name.
# @param   Module name
function docs_bashdoc_for_module() {
    local module_name="$1"
    local path="$docs_path/modules/$module_name"
    local module_path="$(module_get_path $module_name)"

    $(module_get_path docs_bashdoc)/current/bashdoc.sh \
        -p $module_name \
        -o $path \
        `find "$module_path" \( -name bashunit -prune \) -o \( -type f -name "*.sh" -print \)`

    # time to do some file name cleaning
    local module_repo_path="${module_path%/$module_name}"
    local module_repo_dotted="${module_repo_path:1}"
    local module_repo_dotted="${module_repo_dotted//\//.}"
    local new_name=""

    for file in $(find $path -type f); do
        sed -i ".backup" -e "s/${module_repo_dotted//./\\.}\.//g" $file
        sed -i ".backup" -e "s/${module_repo_path//\//\/}//g" $file
        new_name="${file//$module_repo_dotted./}"
        mv $file $new_name
        rm -rf "$path/*.backup"
    done
}
