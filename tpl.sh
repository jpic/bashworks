#!/bin/bash
# framework config
framework_config_model="centralized"
framework_ns="tpl"

# general environment config
tpl_ns="tpl"
tpl_dir=""

# instance specific environment config
declare -a tpl_config_variables[0]="config_dir"
declare -a tpl_config_variables[1]="config_file"
declare -a tpl_config_variables[2]="name"
declare -a tpl_config_variables[3]="config_path"

# example for /etc/tpls/name/config.sh model
function tpl_default_instance() {
    local -i length=${#tpl_config_variables[*]}-1

    for i in `seq 0 $length` ; do
        local key="${framework_ns}_${tpl_config_variables[$i]}"
    
        if ! declare -p "$key" 1>/dev/null 2>/dev/null; then
            case $key in
                "${framework_ns}_config_file")
                    if [[ $framework_config_model == "centralized" ]]; then
                        declare "$key"="config.sh"
                    elif [[ $framework_config_model == "decentralized" ]]; then
                        declare "$key"="${framework_ns}_config.sh"
                    fi
                    ;;
                "${framework_ns}_config_path")
                    if [[ $framework_config_model == "centralized" ]]; then
                        declare "$key"="config.sh"
                    elif [[ $framework_config_model == "decentralized" ]]; then
                        declare "$key"="${framework_ns}_config.sh"
                    fi
                    tpl_config_path="${tpl_config_dir}/${tpl_name}/${tpl_config_file}"
                    ;;
                *)
                    declare "$key"=""
                    ;;
            esac
        fi
    done
}
tpl_default_instance

function tpl_save_instance() {
    local -i length=${#tpl_config_variables[*]}-1

    for i in `seq 0 $length` ; do
        local key=${tpl_config_variables[$i]}
    
        grep -q '^$key="[^"]*"$' $vps_config_file
        if [[ $? -eq 0 ]]; then
            sed -i -e "s@vps_host_ip=.*@vps_host_ip=\"$vps_host_ip\"@" $vps_config_file
        else
            echo "vps_host_ip=\"$vps_host_ip\"" >> $vps_config_file
        fi
    done
}

function tpl_load_instance() {
    
}
