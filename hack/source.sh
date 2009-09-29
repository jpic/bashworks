#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Bash hacks, might break.
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Output something if a variable is a non empty array.
## @param Variable name
#--------------------------
function hack_is_non_empty_array() {
    declare -a | grep $1=\'\(\\[;
}
