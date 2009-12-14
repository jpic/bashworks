#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Linux-vserver management functions.

# Outputs a free id between 100 and 240 by checking $VPS_ETC_DIR.
# @variable $VPS_ETC_DIR should be set to the vps config directory.
function vps_get_free_id() {
    for i in {100..240}; do
        grep -q "vps_id=\"${i}\"" ${VPS_ETC_DIR}/*.config

        if [[ $? != 0 ]]; then
            echo $i
            return 0
        fi
    done
}

# Outputs a config property of another VPS. For example:
## foovps_ip=$(vps_get_property foovps ip)
# @ calls conf_save()
function vps_get_property() {
    local name="$1"
    local property_name="vps_$2"

    conf_save vps
    local current_vps_name=$vps_name

    conf_set vps_name $name
    conf_load vps
    echo ${!property_name}

    if [[ -n $current_vps_name ]]; then
        conf_set vps_master $current_vps_name
        conf_load vps
    fi
    return 0
}

# Generates a VPS, runs almost all functions.
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
    vps_exec emerge -aveK world
}

# For postfixadmin with postgresql ...
# This is the less sucking solution to NOT install smtpd on all vhosts
# @quick-hack this function will probably change a lot
function vps_configure_mail() {
    if [[ -z $VPS_POSTMASTER_PASSWORD ]] || [[ -z $VPS_DOMAIN ]] || [[ -z $VPS_POSTMASTER_THRUSTED ]]; then
        mlog error "Not doing anything unless postfixadmin is used with postgresql in $vps_mailer and you know what you are doing"
        return 2
    fi

    for thrusted in $VPS_POSTMASTER_THRUSTED; do
        vserver $vps_mailer suexec postgres psql -d postfix -c "insert into mailbox (username, password, name, maildir, active, domain, local_part) values ( '${thrusted}@${vps_name}.$VPS_DOMAIN' , '$VPS_POSTMASTER_PASSWORD', 'Postmasters', 'postmaster/', '1', '${vps_name}.$VPS_DOMAIN', 'postmaster' );"
    done
}

# Make the vps mount $vps_packages_dir.
function vps_configure_fstab() {
    echo ${vps_packages_dir} /usr/portage/packages none bind,ro 0 0 >> $VPS_ETC_DIR/$vps_name/fstab
}

# Gets the ip of the $vps_mailer vps and uses it to set the vps "mail" host ip
# to its /etc/hosts
function vps_configure_hosts() {
    local mail_ip=$(vps_get_property $vps_mailer ip)
    echo ${mail_ip} mail >> ${vps_root}/etc/hosts
}

# Copies /etc/portage from the $vps_master vps to the current vps. This is
# useful if all packages and tests should not be done on the host server. 
function vps_configure_portage() {
    local master_root=$(vps_get_property $vps_master root)
    cp -r ${master_root}/etc/portage/* ${vps_root}/etc/portage
}

# Set up the VPS interface to use host dummy0, $vps_ip, $vps_id as name and 24
# as prefix. Also adds net.dummy0 to the vps default runlevel and configures
# the vps /etc/conf.d/net and /etc/resolv.conf
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

# Copies some configuration files from the $vps_admin home directory to the vps
# /root:
# - .ssh/authorized_key*
# - .bashrc
# - .vim*
# - .screenrc
# - .terminfo
function vps_configure_root() {
    mkdir -p ${vps_root}/root/.ssh/
    cp /home/${vps_admin}/.ssh/authorized_key* ${vps_root}/root/.ssh/
    cp -r /home/${vps_admin}/.bashrc ${vps_root}/root
    cp -r /home/${vps_admin}/.vim* ${vps_root}/root
    cp -r /home/${vps_admin}/.screenrc ${vps_root}/root
    cp -R /home/${vps_admin}/.terminfo ${vps_root}/root
}

# Adds sshd to the default vps runlevel.
function vps_configure_runlevels() {
    cd ${vps_root}/etc/runlevels/default
    ln -sfn ../../init.d/sshd .
}

# Downloads $vps_stage_url to $vps_stage_path if it's not already there. Note
# that it sudoes it as nobody.
# @uses sudo -u nobody wget
function vps_getstage() {
    if [[ ! -f ${vps_stage_path} ]]; then
        cd ${vps_stage_path%/*};
        sudo -u nobody wget ${vps_stage_url};
    fi
}

# Wraps around the vserver build command.
# @uses vserver command
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

# enter the vserver
# @uses vserver command
function vps_enter() {
    vserver $vps_name enter
}

# delete the vserver and its config, without warning.
# @uses vserver command
function vps_delete() {
    vserver $vps_name delete
    rm -rf $vps_config_path
}

# starts the vserver
# @uses vserver command
function vps_start() {
    vserver $vps_name start
}

# stops the vserver
# @uses vserver command
function vps_stop() {
    vserver $vps_name stop
}

# restarts the vserver
# @uses vserver command
function vps_restart() {
    vserver $vps_name restart
}

# executes a command in the vps
# @param command to execute
# @uses vserver command
function vps_exec() {
    vserver $vps_name exec $*
}

# deletes all vps which name start with "test" without any warning.
# @variable $vps_config_dir
# @uses vserver delete command
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

# Wrapper to emerge for compiling programs:
# - try to emerge with -K (binpkg)
# - emerge on $vps_master if it required
# - recurses.
# Emerges in $vps_master then from the binpto $vps_name
# @param emerge options
# @call vps_emerge()
# @uses vemerge command
function vps_emerge() {
    vemerge $vps_name -- -K $@

    if [[ $? == 0 ]]; then
        return 0
    fi

    vemerge $vps_master -- -av $@

    if [[ $? != 0 ]]; then
        echo "Emerging on $vps_master did not succeed, not merging binary package to $vps_name"
        return 2
    fi

    vemerge $vps_name -- -Kav $@
}

# Adds the given use flag for the given package atom to the master vps package.keywords and then updates the current vps portage.
# Example usage:
## # Add sqlite use flag to php
## # vps_euse dev-lang/php sqlite
# @calls vps_updateportage 
# @param package atom
# @param use flags
function vps_euse() {
    local atom=$1
    shift 1
    local use=$@

    echo $atom >> $(vps_get_property $vps_master root)/etc/portage/package.keywords

    vps_updateportage
}

# Adds the given package atom to the master vps package.keywords and then
# updates the current server.
# Example usage:
## # You're looking for troubble, and want unstable mysql
## vps_ebackport dev-db/mysql
# @param package atom to add to package.keywords
# @call vps_updateportage
function vps_ebackport() {
    local atom=$1

    echo $atom >> $(vps_get_property $vps_master root)/etc/portage/package.keywords
    
    vps_updateportage
}

# Patch baselayout.
# Baselayout 2 totally fails when used in a vserver guest. This applies the
# require patch for successfull Gentoo vserver guest boot.
function vps_configure_baselayout() {
    /usr/lib/util-vserver/distributions/gentoo/initpost $VPS_ETC_DIR/$vps_name /usr/lib/util-vserver/util-vserver-vars
}
