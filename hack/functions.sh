#!/bin/bash
# -*- coding: utf-8 -*-
# Various bash hacks.

# Check if a variable is a non empty array.
# @stdout  "Yes" if the variable is a non empty array.
# @param   Name of the variable to check.
function hack_is_non_empty_array() {
    declare -a | grep -q $1=\'\(\\[;

    if [[ $? == 0 ]]; then
        echo "Yes"
    fi
}

# Adds each repository path to CDPATH environment variable.
##  # change directory to somemodule, whatever is the current directory
##  cd somemodule
# @variable    CDPATH, repo_path
function hack_cdpath() {
    local repo_path=""

    for path in ${module_paths[*]}; do
        repo_path="${path%/*}"

        if [[ ! $CDPATH =~ "${repo_path}" ]]; then
            export CDPATH+=":${repo_path}"
        fi
    done
}

# Given a relative path, it outputs the realpath.
# The realpath utility uses the realpath(3) function to resolve all symbolic
# links, extra `/' characters and references to /./ and /../ in path.
# @param    Path to make real
# @stdout   Absolute path
function hack_realpath() {
    if hack_which realpath; then
        realpath "$1"
    elif hack_which readlink; then
        readlink -f "$1"
    else
        mlog error "Need either realpath or readlink command"
        return 1
    fi
}

# Cross OS `which` command implementation.
# @param    Command name
function hack_which() {
    local linux=""

    if [[ $OSTYPE =~ bsd ]]; then
        return which -s "$1"
    else
        linux="$(which $1 2>&1)"
        if [[ $linux =~ "no $1" ]]; then
            return 1
        else
            return 0
        fi
    fi
}
