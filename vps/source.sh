#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Template management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

if [[ -z $VPS_DIR ]]; then
    VPS_DIR="/vservers"
fi
if [[ -z $VPS_ETC_DIR ]]; then
    VPS_ETC_DIR="/etc/vservers"
fi

#--------------------------
## Declares module configuration variable names.
#--------------------------
function vps_source() {
    source $(module_get_path vps)/functions.sh
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
    vps_host_ip=""
    vps_conf_path=$(vps_get_conf_path)
}

function vps_get_conf_path() {
    echo $VPS_ETC_DIR/${vps_name}.config
}

#--------------------------
## Prompts the admin for the host ip to use
#--------------------------
function vps_network_setup_interactive() {
    if [[ -z $VPS_INTERNET_MAP ]] || [[ -z $VPS_INTRANET_MAP ]]; then
        print_error "VPS_INTERNET_MAP and VPS_INTRANET_MAP are not set, cannot interactively configure network"
        module_blacklist_add vps
        return 2
    fi

    local choice=""
    local line=""
    
    print_info "Please select the network for this VPS"

    for index in ${!VPS_INTERNET_MAP[@]}; do
        line="${index}) "
        
        if [[ -n $VPS_LABEL_MAP ]]; then
            line+="${VPS_LABEL_MAP[$index]} "
        fi

        line+="${VPS_INTERNET_MAP[$index]} "
        line+="vps_ip: ${VPS_INTRANET_MAP[$index]}${vps_id}"

        echo $line
    done
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

    vps_root="${VPS_DIR}/${vps_name}"

    if [[ ! -f $vps_conf_path ]]; then
        vps_id=$(vps_get_free_id)
        vps_master="master"
        vps_mailer="mail"
        vps_packages_dir="${VPS_DIR}/${vps_master}/usr/portage/packages"
        vps_stage_name="gentoo-vserver-i686-20090611.tar.bz2"
        vps_stage_url="http://bb.xnull.de/projects/gentoo/stages/i686/gentoo-i686-20090611/vserver/${vps_stage_name}";
        vps_stage_path="/tmp/${vps_stage_name}"
        
        vps_network_setup_interactive

        vps_conf_save
    else
        vps_conf_load
    fi
    
    cd $vps_src_path
}
