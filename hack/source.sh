#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#	@Synopsis	Bash hacks, might break.
#	@Copyright	Copyright 2009, James Pic
#	@License	Apache

function hack_load() {
    source $(module_get_path hack)/functions.sh
}

function hack_post_load() {
    hack_cdpath
}
