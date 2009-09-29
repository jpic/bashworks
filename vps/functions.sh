#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	VCS management functions
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

function vps_get_free_id() {
    for i in {100..240}; do
        grep $i "vps_id=\"${i}\"" ${VPS_DIR}/*/${VPS_CONFIG_FILE}

        if [[ $? != 0 ]]; then
            echo $i
            return 0
        fi
    done
}
