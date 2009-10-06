#!/bin/bash
# -*- coding: utf-8 -*-
# The wepcrack module wraps around aircrack-ng.

# Blacklists the wepcrack module which has not been fully ported yet
function wepcrack_pre_source() {
    module_blacklist_add wepcrack
}
