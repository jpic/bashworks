#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Todo management module
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Declares module configuration variable names.
#--------------------------
function todo_source() {
    unset todo_variables
    todo_variables+=("list")
    # prefix variable names
    todo_variables=("${todo_variables[@]/#/todo_}")

    jpic_module_source todo functions.sh
}
