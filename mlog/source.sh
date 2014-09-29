#!/bin/bash
# -*- coding: utf-8 -*-
# Wraps around the _great_ *bashinator* logging library.
# See mlog().

# Loads Bashinator!
function mlog_load() {
    source "$(module_get_path mlog)"/bashinator-0.3.sh
}

# Log a message with a given security.
# Example usage:
## mlog debug   "Something happenned which might help you figuring what TF"
## mlog info    "Some script started correctly"
## mlog notice  "Database is 8 days old"
## mlog warning "Database is older than your father"
## mlog err     "Database is not started"
## mlog crit    "Database crashed"
## mlog alert   "Unsecure data"
## mlog emerg   "Data lost, probably burning in hell" 
function mlog() {
    local level="$1"
    local message="$2"

    __msg $level "$message"
}
