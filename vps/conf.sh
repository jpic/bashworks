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
