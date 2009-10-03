#--------------------------
## Prompts the admin for the host ip to use
#--------------------------
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
    unset vps_ip
    unset vps_intranet
    unset vps_host_ip

    conf_interactive vps
    vps_conf_interactive_network
}
