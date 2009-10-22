#!/bin/bash
# -*- coding: utf-8 -*-
# Configuration overloads for the vps module. Basically it offers a more
# sofisticated way to configure $vps_ip, $vps_intranet and $vps_host_ip, which
# you might want to set yourself in your script that calls `conf() vps`.

# Prompts the admin for the host ip to use.
# Example config:
##  # eth0
##  ROUTER_INTERNET_MAP+=("1.1.1.0")
##  ROUTER_INTRANET_MAP+=("192.168.1.")
##  ROUTER_ZONE_MAP+=("net")
##  ROUTER_LABEL_MAP+=("Non-free (eth0)")
##  # eth1
##  ROUTER_INTERNET_MAP+=("1.1.1.1")
##  ROUTER_INTRANET_MAP+=("192.168.2.")
##  ROUTER_ZONE_MAP+=("net2")
##  ROUTER_LABEL_MAP+=("Free (eth1)")
# Note that those which are really required for vps_conf_interactive_network()
# ar the INTERNET and INTRANET ones. The ZONE one is used by the swall module
# tiein. The LABEL one is just to give your tubes a name, for example we use
# one for clients and one for us and whatever we want to host, so when it says
# "Free" the admin friend who helped, it really means "YAY ENJOY YOUR FREE GBPS
# BRO!".
# @variable $ROUTER_INTERNET MAP: list of internet ips.
# @variable $ROUTER_INTRANET_MAP: list of *corresponding* intranet ips.
# @variable $ROUTER_LABEL_MAP: optionnal.
function vps_conf_interactive_network() {
    if [[ -z $ROUTER_INTERNET_MAP ]] || [[ -z $ROUTER_INTRANET_MAP ]]; then
        mlog warning "ROUTER_INTERNET_MAP and ROUTER_INTRANET_MAP are not set, cannot configure network"
    fi

    local choice=""
    local line=""
    
    mlog info "Please select the network for this ROUTER"

    for index in ${!ROUTER_INTERNET_MAP[@]}; do
        line="${index}) "
        
        if [[ -n $ROUTER_LABEL_MAP ]]; then
            line+="${ROUTER_LABEL_MAP[$index]} "
        fi

        line+="${ROUTER_INTERNET_MAP[$index]} "
        line+="vps_ip: ${ROUTER_INTRANET_MAP[$index]}${vps_id}"

        echo $line
    done

    read -p "Choice number> " choice

    vps_intranet=${ROUTER_INTRANET_MAP[$choice]}
    vps_ip=${vps_intranet}${vps_id}
    vps_host_ip=${ROUTER_INTERNET_MAP[$choice]}
}

# If $ROUTER_INTERNET_MAP and friends are set then use the sofisticated
# multi-interface network routing configurator. Runs normally otherwise.
function vps_conf_interactive() {
    if [[ -z $ROUTER_INTERNET_MAP ]] || [[ -z $ROUTER_INTRANET_MAP ]]; then
        unset vps_ip
        unset vps_intranet
        unset vps_host_ip
    fi

    conf_interactive vps
    
    if [[ -z $ROUTER_INTERNET_MAP ]] || [[ -z $ROUTER_INTRANET_MAP ]]; then
        vps_conf_interactive_network
    fi
}

# Setter for the "master" variable.
# Polite caller:
## conf_set master somevalue
function vps_master_set() {
    vps_master="$1"
    vps_packages_dir="$VPS_DIR/$vps_master/pkgdir"
}

# Setter for the "name" variable.
# Polite caller:
## conf_set name somevalue
function vps_name_set() {
    vps_name="$1"
    vps_root=${VPS_DIR}/${vps_name}
    vps_conf_path=$(vps_conf_get_path)
}

# Setter for the "stage_name" variable.
# Polite caller:
## conf_set stage_name somevalue
function vps_stage_name_set() {
    vps_stage_name="$1"
    vps_stage_url="http://bb.xnull.de/projects/gentoo/stages/i686/gentoo-i686-20090611/vserver/${vps_stage_name}";
    vps_stage_path="/tmp/${vps_stage_name}"
}

# Logs configuration inconsistencies.
function vps_conf_forensic() {
    source $vps_root/etc/make.globals
    source $vps_root/etc/make.conf
    local guest_pkgdir="${PKGDIR}"

    source $(vps_get_property $vps_master root)/etc/make.globals
    source $(vps_get_property $vps_master root)/etc/make.conf
    local master_pkgdir="$(vps_get_property $vps_master root)${PKGDIR}"

    # test guest fstab pkgdir
    local expected="$master_pkgdir $guest_pkgdir"
    if ! grep -q "$expected" $VPS_ETC_DIR/$vps_name/fstab; then
        mlog alert "fstab does not mount master pkgdir ($master_pkgdir) on guest pkgdir ($guest_pkgdir)"
    fi

    source $(vps_get_property $vps_master root)/etc/make.globals
    source $(vps_get_property $vps_master root)/etc/make.conf

    # test master buildpkg feature
    if ! echo $FEATURES | grep -q buildpkg; then
        mlog alert "'buildpkg' not in master portage FEATURES"
    fi
}

# Outputs a list of conf names useable with the vps() conf loading function.
function vps_conf_all() {
    local name

    for name in $VPS_ETC_DIR/*.config; do
        name="${name/$VPS_ETC_DIR\//}"
        name="${name/.config/}"
        echo $name
    done
}
