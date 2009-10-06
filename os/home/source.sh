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
# in the $home_prefix/bin folder.
#
# $home_prefix defaults to $HOME.
#
# Any file from a subdirectory of $home_specifics_preix that matches $OSTYPE
# will be symlinked to the appropriate directory of $home_prefix.

# It will contain directories like bin/, lib/, share/ etc ...
# It is good to use for the --prefix argument of many setup utilities.
export home_prefix="$HOME"

# Should have subdirectories $home_prefix, but should only contain things that
# depend on a particular OS for example things that where built for bsd or
# lunix.
export home_virtual_prefix="$HOME/homes"

# Symlinks any file from a subdirectory of $home_specifics_preix that matches
# $OSTYPE will be symlinked to the appropriate directory of $home_prefix.
function os_home_symlink() {
    local relative_target=""
    local target_file=""
    local target_dir=""

    for home in $(os_home_get_virtual); do
        
        # prepare directories
        for dir in $(find $home -type d); do
            # from /home/jpic/homes/bsd/bin/foo to bin
            relative_target="${dir#$home/}"
            
            # from bin to /home/jpic/bin
            target_dir="$home_prefix/$relative_target"
            
            echo mkdir -p "$target_dir"
        done
    done
}

# Outputs a list of virtual home directories which names match $OSTYPE.
# @stdout   List of directories separated by spaces.
function os_home_get_virtual() {
    local output=""

    for dir in "$home_virtual_prefix"/*; do
        if [[ $OSTYPE =~ "${dir##*/}" ]]; then
            output+="$(hack_realpath $dir) "
        fi
    done

    echo $output
}
