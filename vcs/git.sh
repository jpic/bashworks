#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#	@Synopsis	GIT VCS management functions
#	@Copyright	Copyright 2009, James Pic
#	@License	Apache

# Commits with a given message
# @param Message
function vcs_commit() {
    git commit -m "$*"
}

# Adds the given files to the next commit
# @param Files
function vcs_add() {
    git add $*
}

# Adds the given files to the next commit, interactively
# @param Files
function vcs_add_interactive() {
    git add --interactive $*
}

# Addes the given patterns to the ignore file
# @param Patterns to ignore
function vcs_ignore() {
    echo $* >> $vcs_src_path/.gitignore
}

# Outputs a diff
# @param Files
function vcs_diff() {
    git diff $*
}

# Return 0 if a branch exist
# @param Branch name
function vcs_branch_exists() {
    git branch | grep -q $*
    
    return $?
}


