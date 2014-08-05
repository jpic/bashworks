#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# VCS wrapper, for git only right now.

# Sources functions and aliases.
function vcs_load() {
    source "$(module_get_path vcs)"/aliases.sh
}

# Sets variable defaultts.
function vcs_post_load() {
    vcs_src_path=""
    vcs_type=""
    vps_conf_path=$(vcs_get_conf_path)
}

# Returns $vps_src_path/.vcs.sh
function vcs_get_conf_path() {
    echo ${vcs_src_path}/.vcs.sh
}

# Initialises the vcs module in a given sources path.
# @param Path to sources root
function vcs() {
    local usage="vcs /path/to/sources"
    vcs_src_path="$1"

    if [[ -z $vcs_src_path ]]; then
        mlog error "Usage: $usage"
        return 2
    fi

    if [[ ! -f $vcs_src_path/.vcs.sh ]]; then
        vcs_conf_save
    else
        vcs_conf_load
    fi

    cd $vcs_src_path

    if [[ -z $vcs_type ]]; then
        for vcs_type in git hg svn; do
            mlog debug "Checking for $vcs_type in $vcs_src_path"
            if [[ -d ".$vcs_type" ]]; then
                mlog debug "Found $vcs_type in $vcs_src_path"
                source "$(module_get_path vcs)"/${vcs_type}.sh
            fi
        done
    fi
}
