#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	GIT VCS management functions
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Commits with a given message
## @param Message
#--------------------------
function vps_commit() {
    git commit -m "$*"
}

#--------------------------
## Adds the given files to the next commit
## @param Files
#--------------------------
function vps_add() {
    git add $*
}

#--------------------------
## Adds the given files to the next commit, interactively
## @param Files
#--------------------------
function vps_add_interactive() {
    git add --interactive $*
}

#--------------------------
## Addes the given patterns to the ignore file
## @param Patterns to ignore
#--------------------------
function vps_ignore() {
    echo $* >> $vps_src_path/.gitignore
}

#--------------------------
## Outputs a diff
## @param Files
#--------------------------
function vps_diff() {
    git diff $*
}

#--------------------------
## Return 0 if a branch exist
## @param Branch name
#--------------------------
function vps_branch_exists() {
    git branch | grep -q $*
    
    return $?
}


