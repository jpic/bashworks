#!/bin/bash
# -*- coding: utf-8 -*-

# Install binary packages.
# @param    One or several package names.
function os_pkg_bin_install() {
    while [[ -n "$1" ]]; do
        emerge -vGK "$1"
        shift
    done
}

# Configure a source package which will be built.
# @todo abstract this
# @param    One or several package names.
function os_pkg_src_configure() {
    while [[ -n "$1" ]]; do
        emerge -pv "$1"
        shift
    done   
}

# Build a configured source package.
# @param    One or several package names.
function os_pkg_src_build() {
    while [[ -n "$1" ]]; do
        emerge -b -v "$1"
        shift
    done
}

# Install a built source package. 
# @param    One or several package names.
function os_pkg_src_install() {
    while [[ -n "$1" ]]; do
        emerge -K "$1"
        shift
    done
}

# Removes an installed package without any warning.
# @param    One or several package names.
function os_pkg_remove() {
    while [[ -n "$1" ]]; do        
        emerge -C "$1"
        shift
    done   
}

# Search a package.
# @todo use eix if available
# @param    One package name.
function os_pkg_search() {
    emerge -s "$*"
}

# Go into the port directory of a package.
# @param    One package name.
# @todo     Do the actual implementation.
function os_pkg_cd_source() {
    echo "not implemented"
}
