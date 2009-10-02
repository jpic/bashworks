#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Template management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

function vps_pre_source() {
    if [[ -z $VPS_INTERNET_MAP ]] || [[ -z $VPS_INTRANET_MAP ]]; then
        print_error "VPS_INTERNET_MAP and VPS_INTRANET_MAP are not set, \
                     cannot interactively configure network"
        module_blacklist_add vps
        return 2
    fi

    if [[ -z $VPS_DIR ]]; then
        VPS_DIR="/vservers"
    fi
    
    if [[ -z $VPS_ETC_DIR ]]; then
        VPS_ETC_DIR="/etc/vservers"
    fi
}

#--------------------------
## Declares module configuration variable names.
#--------------------------
function vps_source() {
    source $(module_get_path vps)/functions.sh
    source $(module_get_path vps)/conf.sh
}

function vps_post_source() {
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
    vps_conf_path=$(vps_get_conf_path)
}

function vps_get_conf_path() {
    echo $VPS_ETC_DIR/${vps_name}.config
}

#--------------------------
## Initialises a vps configuration with a given name
## @param VPS name
## @param Silent (optionnal)
#--------------------------
function vps() {
    local usage="vps \$vps_name"
    vps_name="$1"

    if [[ -z $vps_name ]]; then
        print_error "Usage: $usage"
    fi

    vps_conf_path=$(vps_get_conf_path)

    if [[ ! -f $vps_conf_path ]]; then
        print_info $vps_conf_path not found, configuring new vps

        vps_root=${VPS_DIR}/${vps_name}
        vps_id=$(vps_get_free_id)
        vps_admin=$USER
        vps_master="master"
        vps_mailer="mail"
        vps_packages_dir="${VPS_DIR}/${vps_master}/usr/portage/packages"
        vps_stage_name="gentoo-vserver-i686-20090611.tar.bz2"
        vps_stage_url="http://bb.xnull.de/projects/gentoo/stages/i686/gentoo-i686-20090611/vserver/${vps_stage_name}";
        vps_stage_path="/tmp/${vps_stage_name}"

        conf vps
    else
        conf_load vps
    fi
    
    cd $vps_src_path
}
