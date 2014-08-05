#!/bin/bash
# -*- coding: utf-8 -*-
# This module helps to manage the home directory for multiple oses. It is for
# users who use a lot of --prefix options set to their $HOME directory.
# For example, sharing $HOME/bin on GNU/Linux and BSD will not work very well;
# thus the simple purpose of this module.
# 
# Its purpose is to setup your $HOME directory depending on the current OS.
#
# Files which should be useable with any OS like Perl, Python scripts can live
# in the $os_home_prefix/bin folder.
#
# $os_home_prefix defaults to $HOME.
#
# Any file from a subdirectory of $os_home_specifics_preix that matches $OSTYPE
# will be symlinked to the appropriate directory of $os_home_prefix.

# It will contain directories like bin/, lib/, share/ etc ...
# It is good to use for the --prefix argument of many setup utilities.
export os_home_real_prefix="$HOME"

# Should have subdirectories $os_home_prefix, but should only contain things that
# depend on a particular OS for example things that where built for bsd or
# lunix. It could contain directories like bsd, freebsd8, linux ...
export os_home_repo="$HOME/homes"

# The current home to use. This is different from $os_home_real_prefix because
# this should be the path of one of the os-specific subdirectories of
# $os_home_repo.
export os_home_current_prefix=""

# Loads functions and conf overloads.
function os_home_load() {
    source "$(module_get_path os_home)"/functions.sh
    source "$(module_get_path os_home)"/conf.sh
}

# Sets $os_home_current_prefix to the first subdirectory of $os_home_repo that
# matches $OSTYPE.
function os_home_post_load() {
    os_home_current_prefix="$(os_home_get_homedir)"
}
