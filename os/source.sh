#!/usr/bin/env bash
# In its early version, it just figures the os in a more general way than
# $OSTYPE.
# The plan: port multi-os compiles and bin/ symlinks from my .bashrc

# Sets $os_type to bsd or linux.
function os_source() {
    uname -a | grep -q -i bsd
    if [[ $? -eq 0 ]]; then
        os_type=bsd
    else
        os_type=linux
    fi
}
