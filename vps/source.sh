#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# VPS management module, currently only supporting Linux-Vserver and Gentoo
# GNU/Linux.
# Example usage:
## vps yourvps
## vps_generate
## vps_enter
# See vps functions documentation for more information.

# Sets the default globals if required.
# @variable $VPS_DIR
# @variable $VPS_ETC_DIR
function vps_pre_load() {
    if [[ -z $VPS_DIR ]]; then
        VPS_DIR="/vservers"
    fi
    
    if [[ -z $VPS_ETC_DIR ]]; then
        VPS_ETC_DIR="/etc/vservers"
    fi
}

# Declares module configuration variable names.
function vps_load() {
    source $(module_get_path vps)/functions.sh
    source $(module_get_path vps)/conf.sh
}

# Unsets all vps variables.
function vps_post_load() {
    vps_name=""
    vps_root=""
    vps_id=""
    vps_packages_dir=""
    vps_master=""
    vps_mailer=""
    vps_stage_name=""
    vps_stage_url=""
    vps_admin=""
    vps_ip=""
    vps_intranet=""
    vps_host_ip=""
    vps_conf_path=$(vps_conf_get_path)
}

function vps_conf_get_path() {
    echo $VPS_ETC_DIR/${vps_name}.config
}

# Initialises a vps configuration with a given name
# @param VPS name
function vps() {
    local usage="vps \$vps_name"
    conf_set vps_name "$1"

    if [[ ! -f $vps_conf_path ]]; then
        mlog info $vps_conf_path not found, configuring new vps

        vps_root=${VPS_DIR}/${vps_name}
        vps_id=$(vps_get_free_id)
        vps_admin=$USER
        vps_master="master"
        vps_mailer="mail"
        vps_packages_dir="${VPS_DIR}/${vps_master}/pkgdir"
        vps_stage_name="gentoo-vserver-i686-20090611.tar.bz2"
        vps_stage_url="http://bb.xnull.de/projects/gentoo/stages/i686/gentoo-i686-20090611/vserver/${vps_stage_name}";
        vps_stage_path="/tmp/${vps_stage_name}"

        conf vps
    else
        conf_load vps
    fi
    
    cd $vps_src_path
}
