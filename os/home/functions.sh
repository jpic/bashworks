#!/bin/bash
# -*- coding: utf-8 -*-
# OS/home management functions.

# Symlinks any file from a subdirectory of $os_home_specifics_preix that matches
# $OSTYPE will be symlinked to the appropriate directory of $os_home_prefix.
function os_home_symlink() {
    local relative_target=""
    local target_file=""
    local target_dir=""

    for home in $(os_home_get_homedirs); do
        
        # prepare directories
        for dir in $(find $home -type d); do
            # from /home/jpic/homedirs/bsd/bin/foo to bin
            relative_target="${dir#$home/}"
            
            # from bin to /home/jpic/bin
            target_dir="$os_home_prefix/$relative_target"

            if [[ ! -d "$target_dir" ]]; then
                mlog info "Creating missing target directory: $target_dir"
            fi
            mkdir -p "$target_dir"
        done

        # symlink any file
        for file in $(find $home -type f); do
            # from /home/jpic/homedirs/bsd/bin/foo to bin/foo
            relative_target="${file#$home/}"
            
            # from bin/foo to /home/jpic/bin/foo
            target_file="$os_home_prefix/$relative_target"
            
            ln -sfn $file $target_file
        done
    done
}

# Outputs a list of repo home directories which names match $OSTYPE.
# @stdout   List of directories separated by spaces.
function os_home_get_homedirs() {
    local output=""

    for dir in "$os_home_repo"/*; do
        if [[ $OSTYPE =~ "${dir##*/}" ]]; then
            output+="$(hack_realpath $dir) "
        fi
    done

    echo $output
}

# Outputs the first homedir of the homes repo that matches $OSTYPE.
# @stdout   Path to the homedir.
function os_home_get_homedir() {
    local output=""

    for dir in "$os_home_repo"/*; do
        if [[ $OSTYPE =~ "${dir##*/}" ]]; then
            echo $dir
            return 0
        fi
    done
}
