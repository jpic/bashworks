#!/bin/bash
# script config {{{
DEFAULT_CONFIG="config"

# iptables config
vps_dir="/vservers"
vps_config_dir="/etc/vservers"
vps_packages_dir="/vservers/master/usr/portpage/packages"
vps_ssh_timeout=60
max_timeout=600

# eth0
vps_internet_map+=("88.191.110.204")
vps_intranet_map+=("192.168.1.")
# eth1
vps_internet_map+=("88.191.108.204")
vps_intranet_map+=("192.168.2.")

# build config
stage_name="gentoo-vserver-i686-20090611.tar.bz2";
stage_url="http://bb.xnull.de/projects/gentoo/stages/i686/gentoo-i686-20090611/vserver/${stage_name}";
stage_dir="/tmp";
stage_path="${stage_dir}/${stage_name}";

# configurable vserver
if [[ $vps_config_file == "" ]]; then vps_config_file="$DEFAULT_CONFIG"; fi
if [[ $vps_host_ip == "" ]]; then vps_host_ip="88.191.110.204"; fi
if [[ $vps_id == "" ]]; then vps_id=""; fi
if [[ $vps_ip == "" ]]; then vps_ip=""; fi
if [[ $vps_name == "" ]]; then vps_name=""; fi
if [[ $vps_root == "" ]]; then vps_root=""; fi
if [[ $vps_intranet == "" ]]; then vps_intranet=""; fi
if [[ $vps_master == "" ]]; then vps_master="master"; fi
if [[ $vps_admin == "" ]]; then read -p "Enter your username: " vps_admin; fi
if [[ $vps_config_path == "" ]]; then vps_config_path="$DEFAULT_CONFIG"; fi
# }}}


function vps_help() {
    echo ".."
}
vps_help


# vps_ssh <port> [ <timeout: int seconds> ] # {{{
function vps_ssh() {
    if [[ $1 == "" ]]; then
    	echo "Usage: vps_ssh <port>"
    	return 2
    fi

    if [[ $2 ]]; then
        vps_ssh_timeout=$2
    fi

    port=$1

    iptables -t nat -A POSTROUTING -s ${vps_intranet}0/24 \
        -d ! ${vps_intranet}0/24 -j SNAT --to-source $vps_host_ip
    
    iptables -t nat -A PREROUTING -s ! ${vps_intranet}0/24 \
        -m tcp -p tcp --dport $port \
        -j DNAT --to-destination $vps_ip:22

    echo "You have $vps_ssh_timeout seconds to ssh connect to $vps_host_ip:$port";   
    echo "ssh -p $port $vps_host_ip # please paste this command dear master"

    sleep $vps_ssh_timeout

    iptables -t nat -D POSTROUTING -s ${vps_intranet}0/24 \
        -d ! ${vps_intranet}0/24 -j SNAT --to-source $vps_host_ip
    
    iptables -t nat -D PREROUTING -s ! ${vps_intranet}0/24 \
        -m tcp -p tcp --dport $port \
        -j DNAT --to-destination $vps_ip:22
} #}}}
# vps_save_config [<config file=vps_config_file>] # {{{
#
# Can overwrite vps_config_file
#
# Saves all our env variables to the config file
# Tryes to just overwrite variable values if the file exists
# Also sets $root to the current directory
function vps_save_config() {
    local current=`pwd`

    cd $vps_config_dir
    touch $vps_config_file

    if [[ $1 ]]; then
        vps_config_file="$1"
    fi

    if [[ -f $vps_config_dir/$vps_config_file ]]; then
        echo "updating $vps_config_file"
    else
        echo "creating $vps_config_file"
        echo "#!/bin/bash" > $vps_config_file
        echo "" >> $vps_config_file
    fi

    grep -q '^vps_config_file="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_config_file=.*@vps_config_file=\"$vps_config_file\"@" $vps_config_file
    else
        echo "vps_config_file=\"$vps_config_file\"" >> $vps_config_file
    fi

    grep -q '^vps_host_ip="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_host_ip=.*@vps_host_ip=\"$vps_host_ip\"@" $vps_config_file
    else
        echo "vps_host_ip=\"$vps_host_ip\"" >> $vps_config_file
    fi

    grep -q '^vps_ip="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_ip=.*@vps_ip=\"$vps_ip\"@" $vps_config_file
    else
        echo "vps_ip=\"$vps_ip\"" >> $vps_config_file
    fi

    grep -q '^vps_name="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_name=.*@vps_name=\"$vps_name\"@" $vps_config_file
    else
        echo "vps_name=\"$vps_name\"" >> $vps_config_file
    fi

    grep -q '^vps_id="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_id=.*@vps_id=\"$vps_id\"@" $vps_config_file
    else
        echo "vps_id=\"$vps_id\"" >> $vps_config_file
    fi

    grep -q '^vps_intranet="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_intranet=.*@vps_intranet=\"$vps_intranet\"@" $vps_config_file
    else
        echo "vps_intranet=\"$vps_intranet\"" >> $vps_config_file
    fi

    grep -q '^vps_master="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_master=.*@vps_master=\"$vps_master\"@" $vps_config_file
    else
        echo "vps_master=\"$vps_master\"" >> $vps_config_file
    fi

    grep -q '^vps_root="[^"]*"$' $vps_config_file
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@vps_root=.*@vps_root=\"$vps_root\"@" $vps_config_file
    else
        echo "vps_root=\"$vps_root\"" >> $vps_config_file
    fi

    cd $current
} #}}}
# vps_load_config <vps_name> # {{{
#
# Loads $vps_config_dir/$vps_name.config and updates PS1
function vps_load_config() {
    usage="vps_load_config <vps_name>"

    vps_name=$1

    if [[ $vps_name == "" ]]; then
        echo $usage
        return 2
    fi

    source $vps_config_dir/${vps_name}.config

    echo $PS1 | grep -q "(vps:[^)]*)"

    if [[ $? == "0" ]]; then
        PS1=`echo ${PS1} | sed -e "s/(vps:[^)]*)/(vps:${vps_name})/"`
    else
        PS1="(vps:${vps_name}) $PS1"
    fi
} # }}}
# vps_create_config <vps_id> <vps_name> [<vps_host_ip="88.191.110.204">] # {{{
# 
# Sets up your environment to create a new vps.
function vps_create_config() {
    if [[ $1 == "" ]] || [[ $2 == "" ]]; then
        echo "Usage: vps_create_config <vps_id> <vps_name> [<vps_host_ip="88.191.110.204">]"
        return 2
    fi

    vps_id=$1
    vps_name=$2
    vps_root=$vps_dir/$vps_name
    vps_config_file=$vps_name.config

    if [[ $3 != "" ]]; then
        vps_host_ip=$3
    fi

    for i in `seq 0 $((${#vps_internet_map[@]}-1))`; do
        if [[ ${vps_internet_map[$i]} == $vps_host_ip ]]; then
            vps_intranet=${vps_intranet_map[$i]}
            vps_ip="${vps_intranet_map[$i]}${vps_id}"
            break
        fi
    done

    if [[ $vps_ip == "" ]]; then
        echo "*BUG* No intranet found for host ip $vps_host_ip"
        return 2
    fi

    vps_save_config
    vps_load_config $vps_name

    echo "VPS configuration set up, check and run vps_generate or DIY"
} # }}}
function vps_generate() { # {{{
    vps_getstage
    vps_build
    vps_setnet
    vps_setportage
    vps_setpreferences
    vps_save_config
    vps_start
    vps_updateportage
} # }}}
function vps_setportage() { # {{{
    echo $vps_packages_dir /usr/portage/packages none bind,ro 0 0 >> $vps_root/etc/fstab
} # }}}
function vps_updateportage() { # {{{{
    local current_root=$vps_root
    local current_vps=$vps_name
    vps_load_config $vps_master
    cp -r $vps_root/etc/portage/* $current_root/etc/portage
    echo $atom $use >> $vps_root/etc/portage/package.use
    vps_load_config $current_vps
} # }}}
function vps_setpreferences() { # {{{
    mkdir -p $vps_root/root/.ssh/
    cp /home/$vps_admin/.ssh/authorized_key* $vps_root/root/.ssh/
    cp -r /home/$vps_admin/.bashrc $vps_root/root
    cp -r /home/$vps_admin/.vim* $vps_root/root
    cp -r /home/$vps_admin/.screenrc $vps_root/root
    cp -r /home/$vps_admin/.terminfo $vps_root/root
} # }}}
function vps_setnet() { # {{{
    # vserver config
    cd /etc/vservers/$vps_name/interfaces/0
    echo dummy0 > dev
    echo $vps_ip > ip
    echo $vps_id > name
    echo 24 > prefix #wtf is this?

    # copy nameservers
    cp -L /etc/resolv.conf $vps_root/etc;
    
    # add net.dummy0 config
    cd $vps_root/etc/init.d/;
    ln -sfn net.lo net.dummy0;
    
    # add to default runlvel
    cd $vps_root/etc/runlevels/default;
    ln -sfn ../../init.d/dummy.eth0 .;
    
    # net config
    echo config_dummy0=\"$vps_ip netmask 255.255.255.0\" >> $vps_root/etc/conf.d/net
} # }}}
function vps_getstage() { # {{{
    if [[ ! -f $stage_path ]]; then
        cd $stage_dir;
        sudo -u nobody wget $stage_url;
    fi
} # }}}
function vps_build() { # {{{
    vserver $vps_name build \
        --context $vps_id \
        --hostname $vps_name \
        --interface eth0:$vps_ip/24 \
        --initstyle gentoo \
        -m template -- \
            -d gentoo \
            -t $stage_path

    cd $vps_root/etc/runlevels/default
    ln -sfn ../../init.d/sshd .
} # }}}
function vps_enter() { # {{{
    vserver $vps_name enter
} # }}}
function vps_delete() { # {{{
    vserver $vps_name delete
    rm $vps_config_path
} # }}}
function vps_start() { # {{{
    vserver $vps_name start
} # }}}
function vps_stop() { # {{{
    vserver $vps_name stop
} # }}}
function vps_restart() { # {{{
    vserver $vps_name restart
} # }}}
function vps_exec() { # {{{
    vserver $vps_name exec $@
} # }}}
function vps_delete_test_vps() { # {{{
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
} # }}}
# vps_emerge <emerge options> {{{
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
} # }}}
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
