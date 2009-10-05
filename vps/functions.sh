#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#	@Synopsis	VCS management functions
#	@Copyright	Copyright 2009, James Pic
#	@License	Apache

# Outputs a free id between 100 and 240
function vps_get_free_id() {
    for i in {100..240}; do
        grep -q "vps_id=\"${i}\"" ${VPS_ETC_DIR}/*.config

        if [[ $? != 0 ]]; then
            echo $i
            return 0
        fi
    done
}

function vps_get_property() {
    local name="$1"
    local property_name="vps_$2"

    conf_save vps
    local current_vps_name=$vps_name

    vps $name 1
    echo ${!property_name}

    vps $vps_name 1
    return 0
}

# Generates a VPS
function vps_generate() {
    vps_getstage
    vps_build
    vps_configure_fstab
    vps_configure_hosts
    vps_configure_portage
    vps_configure_net
    vps_configure_root
    vps_configure_runlevels
    conf_save vps
    vps_start
}

function vps_configure_fstab() {
    echo ${vps_packages_dir} /usr/portage/packages none bind,ro 0 0 >> ${vps_root}/etc/fstab
}

function vps_configure_hosts() {
    local mail_ip=$(vps_get_property $vps_mailer ip)
    echo ${mail_ip} mail >> ${vps_root}/etc/hosts
}

function vps_configure_portage() {
    local master_root=$(vps_get_property $vps_master root)
    cp -r ${master_root}/etc/portage/* ${vps_root}/etc/portage
}

function vps_configure_net() {
    local workdir=`pwd`

    cd ${VPS_ETC_DIR}/${vps_name}/interfaces/0
    echo dummy0 > dev
    echo $vps_ip > ip
    echo $vps_id > name
    echo 24 > prefix #wtf is this?

    # add net.dummy0 config
    cd ${vps_root}/etc/init.d/;
    ln -sfn net.lo net.dummy0;
    
    # add to default runlvel
    cd $vps_root/etc/runlevels/default;
    ln -sfn ../../init.d/dummy.eth0 .;
    
    # net config
    echo config_dummy0=\"${vps_ip} netmask 255.255.255.0\" >> ${vps_root}/etc/conf.d/net
    
    # copy nameservers
    cp -L /etc/resolv.conf ${vps_root}/etc;
    
    cd $workdir
}

function vps_configure_root() {
    mkdir -p ${vps_root}/root/.ssh/
    cp /home/${vps_admin}/.ssh/authorized_key* ${vps_root}/root/.ssh/
    cp -r /home/${vps_admin}/.bashrc ${vps_root}/root
    cp -r /home/${vps_admin}/.vim* ${vps_root}/root
    cp -r /home/${vps_admin}/.screenrc ${vps_root}/root
    cp -R /home/${vps_admin}/.terminfo ${vps_root}/root
}

function vps_configure_runlevels() {
    cd ${vps_root}/etc/runlevels/default
    ln -sfn ../../init.d/sshd .
}

function vps_getstage() {
    if [[ ! -f ${vps_stage_path} ]]; then
        cd ${vps_stage_path%/*};
        sudo -u nobody wget ${vps_stage_url};
    fi
}

function vps_build() {
    vserver ${vps_name} build \
        --context ${vps_id} \
        --hostname ${vps_name} \
        --interface eth0:${vps_ip}/24 \
        --initstyle gentoo \
        -m template -- \
            -d gentoo \
            -t ${vps_stage_path}
}

function vps_enter() {
    vserver $vps_name enter
}
function vps_delete() {
    vserver $vps_name delete
    rm -rf $vps_config_path
}
function vps_start() {
    vserver $vps_name start
}
function vps_stop() {
    vserver $vps_name stop
}
function vps_restart() {
    vserver $vps_name restart
}
function vps_exec() {
    vserver $vps_name exec $*
}
function vps_delete_test_vps() {
    current=`pwd`

    cd $vps_config_dir
    for name in test*; do
        if [[ -d $name ]]; then
            vserver $name delete
        else
            unlink $name
        fi
    done

    cd $current
}
# vps_emerge <emerge options>
#
# Emerges in $vps_master then from the binpkg to $vps_name
function vps_emerge() {
    vemerge $vps_name -- -K $@

    if [[ $? == 0 ]]; then
        return 0
    fi

    vemerge $vps_master -- $@

    if [[ $? != 0 ]]; then
        echo "Emerging on $vps_master did not succeed, not merging binary package to $vps_name"
        return 2
    fi

    vemerge $vps_name -- -Kav $@
}
# vps_use <package atom> <flags>
function vps_euse() {
    local atom=$1
    shift 1
    local use=$@

    local current_vps=$vps_name
    vps_load_config $vps_master
    echo $atom $use >> $vps_root/etc/portage/package.use
    vps_load_config $current_vps

    vps_updateportage
}
# vps_backport <package atom>
function vps_ebackport() {
    local atom=$1

    local current_vps=$vps_name
    vps_load_config $vps_master
    echo $atom >> $vps_root/etc/portage/package.keywords
    vps_load_config $current_vps
    
    vps_updateportage
}
