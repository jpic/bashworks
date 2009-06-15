#!/bin/bash
# script config {{{
DEFAULT_CONFIG="config"

# iptables config
iptables_protector=/tmp/protect_iptables
vps_dir="/vservers"
vps_config_dir="/etc/vservers"
vps_packages_dir="/vservers/master/usr/portpage/packages"
vps_ssh_timeout=600
max_timeout=600
declare -a nat_internet_mapper[1]="88.191.110.204"
declare -a nat_internet_mapper[2]="88.191.108.204"

declare -a nat_intranet_mapper[1]="192.168.1."
declare -a nat_intranet_mapper[2]="192.168.2."

# build config
stage_name="stage3-i686-current.tar.bz2";
stage_url="http://bb.xnull.de/projects/gentoo/stages/i686/${stage_name}";
stage_dir="/tmp";
stage_path="${stage_dir}/${stage_name}";

# configurable vserver
if [[ $vps_config_file == "" ]]; then vps_config_file="$DEFAULT_CONFIG"; fi
if [[ $vps_host_ip == "" ]]; then vps_host_ip="88.191.110.204"; fi
if [[ $vps_id == "" ]]; then vps_id=""; fi
if [[ $vps_ip == "" ]]; then vps_ip=""; fi
if [[ $vps_name == "" ]]; then vps_name=""; fi
if [[ $vps_root == "" ]]; then vps_root=""; fi
if [[ $vps_config_path == "" ]]; then vps_config_path="$DEFAULT_CONFIG"; fi
# }}}


function vps_help() {
    echo ".."
}
vps_help


# vps_ssh <port> # {{{
function vps_ssh() {
    if [[ $1 == "" ]]; then
    	echo "Usage: vps_ssh <port>"
    	return 2
    fi

    port=$1

    iptables -t nat -A POSTROUTING -s 192.168.1.0/24 \
        -d ! 192.168.1.0/24 -j SNAT --to-source $vps_host_ip
    
    iptables -t nat -A PREROUTING -s ! 192.168.1.0/24 \
        -m tcp -p tcp --dport $port \
        -j DNAT --to-destination $vps_ip:$vport

    echo "You have $vps_ssh_timeout seconds to ssh connect to $vps_host_ip:$port";   
    block_iptables $vps_ssh_timeout
} #}}}
# block_iptables <timeout> # {{{ 
function block_iptables() { 
    if [[ $1 == "" ]]; then
    	echo "Usage: block_iptables <timeout (seconds)>"
    	return 2
    fi

    timeout=$1

    my_block=`date +%s`
    echo $my_block > $iptables_protector
    sleep $timeout

    if [[ ! -f $protector ]]; then
        echo "*BUG* Something removed $protector."
        echo "      Functions should only remove $protector when it contains"
        echo "      the timestamp set by the function itself."
        echo "      I'll continue my job and reset iptables anyway"
        actual_block=$my_block
    else
        actual_block=`cat $protector`
    fi

    if [[ $actual_block != $my_block ]]; then
        echo "*NOT* reseting iptables *yet*, a concurant block was requested."
        return 0
    else
        echo "Time up, resetting iptables"
        unlink $iptables_protector;:
        shorewall clear
        shorewall refresh
    fi
} # }}}
function is_blocked_iptables() { # {{{
    if [[ -f $protector ]]; then
        return true
    else
        return false
    fi
}
#}}}
# vps_save [<config file=vps_config_file>] # {{{
#
# Can overwrite vps_config_file
#
# Saves all our env variables to the config file
# Tryes to just overwrite variable values if the file exists
# Also sets $root to the current directory
function vps_save() {
    local current=`pwd`

    cd $vps_config_dir
    touch $vps_config_file

    if [[ $1 ]]; then
        vps_config_file="$1"
    fi

    if [[ -f $vps_config_file ]]; then
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

    cd $current
} #}}}
# vps_load_config [<config file>] # {{{
#
# Loads a config file, which is determined in this order:
# - a config file path was specified to "vps_load_config": use $1
# - vps_config_file is not "": use vps_config_file
# - use config
function vps_load_config() {
    if [[ $1 ]]; then
        source $1
    elif [[ $vps_config_file ]]; then
        source $vps_config_file
    elif [[ -f $DEFAULT_CONFIG ]]; then
        source $DEFAULT_CONFIG
    else
        echo "Nothing to vps_load_config"
        return -1
    fi

    if [[ `echo $PS1 | grep dev` ]]; then
        # Polite placeholder
        echo "Shell ready to conquer the world, dear master"
    else
        echo "$vps_config_file loaded"
        PS1="(vserver:${vps_name}) $PS1"
    fi

    tag_update
}
# }}}
# vps_hack [<vps_name> [<config>]] # {{{
function vps_hack() {
    if [[ -f $vps_config_file ]]; then
        vps_save
    fi

    if [[ "$1" ]]; then
        vps_name="$1"
        test=$vps_config_dir/$vps_name
        if [[ ! -d $test ]]; then
            echo "Can't find $test!"
            return 2
        fi
    fi

    if [[ $2 && -f $2 ]]; then
        vps_load_config $2
    elif [[ -f $vps_config_file ]]; then
        vps_load_config $vps_config_file
    else
        vps_save
    fi
}
# }}}
# vps_init <vps_id> <vps_name> [<vps_host_ip="88.191.110.204">] # {{{
# 
# Sets up your environment to create a new vps.
function vps_init() {
    if [[ $1 == "" ]] || [[ $2 == "" ]]; then
        echo "Usage: vps_init <vps_id> <vps_name> [<vps_host_ip="88.191.110.204">]"
        return 2
    fi

    vps_id=$1
    vps_name=$2
    vps_root=$vps_dir/$vps_name
    vps_config_file=$vps_name.config

    if [[ $3 != "" ]]; then
        vps_host_ip=$3
    fi

    for i in `seq 1 ${#nat_internet_mapper[*]}` ; do
        if [[ ${nat_internet_mapper[$i]} == "" ]]; then
            break # avoid empty last item
        fi

        if [[ ${nat_internet_mapper[$i]} == $vps_host_ip ]]; then
            vps_ip="${nat_intranet_mapper[$i]}${vps_id}";
        fi
    done

    if [[ $vps_ip == "" ]]; then
        echo "*BUG* No intranet found for host ip $vps_host_ip"
        return 2
    fi

    vps_save

    echo "VPS configuration set up, check and run vps_generate or DIY"
} # }}}
function vps_generate() { # {{{
    vps_getstage
    vps_build
    vps_setnet
    vps_setportage
    vps_setpreferences
    vps_save
    vps_start
} # }}}
function vps_start() { # {{{
    vserver $vps_name start
} # }}}
function vps_setportage() { # {{{
    echo $vps_packages_dir /usr/portage/packages none bind,ro 0 0 >> $vps_root/etc/fstab
} # }}}
function vps_setpreferences() { # {{{
    echo "*WARNING* you should overload this function which installs jpic's preferences"

    # copy jpic ssh pubkey
    mkdir -p $vserver_path/root/.ssh/
    cp /home/jpic/.ssh/authorized_key* $vserver_path/root/.ssh/
} # }}}
function vps_setnet() { # {{{
    # vserver config
    mkdir -p /etc/vservers/$vps_name/interfaces/0
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
# vps_gestage # {{{
function vps_getstage() {
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
} # }}}
