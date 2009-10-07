#!/bin/bash
# -*- coding: utf-8 -*-

# Install binary packages.
# @param    One or several package names.
function os_pkg_bin_install() {
    while [[ -n "$1" ]]; do
        pkg_add -r "$1"
        shift
    done
}

# Configure a source package which will be built.
# @todo abstract this
# @param    One or several package names.
function os_pkg_src_configure() {
    while [[ -n "$1" ]]; do
        os_pkg_cd_source "$1"
        make config-recursive
        shift
    done   
}

# Build a configured source package.
# @param    One or several package names.
function os_pkg_src_build() {
    while [[ -n "$1" ]]; do
        os_pkg_cd_source "$1"
        make
        shift
    done
}

# Install a built source package.
# @param    One or several package names.
function os_pkg_src_install() {
    while [[ -n "$1" ]]; do
        os_pkg_cd_source "$1"
        make
        shift
    done
}

# Removes an installed package without any warning.
# @param    One or several package names.
function os_pkg_remove() {
    while [[ -n "$1" ]]; do        
        pkg_delete "$1"
        shift
    done   
}

# Search a package.
# @todo de-hardcode /usr/ports
# @param    One package name.
function os_pkg_search() {
    local curdir="$(pwd)"
    cd /usr/ports
    make search name="$*"
    cd $curdir
}

# Go into the port directory of a package.
# @todo de-hardcode /usr/ports
# @param    One package name.
function os_pkg_cd_source() {
    for dir in `whereis $1`; do

        if [[ $1 =~ "/usr/ports/" ]]; then
            cd $1
        fi

    done
}
