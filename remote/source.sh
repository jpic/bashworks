#!/bin/bash
# This bash module was inspired by programs like "capistrano", "fabric" ... The
# role of this deployment tool is to make the process of running commands and
# functions on one or several remote servers through ssh.
#
# Like other bashworks modules, it does not provide inversion of control, which
# means that it is left to the user to make a script that will use functions
# from the deploy module.
#
# It is recommanded that $HOME/.ssh/config is nicely configured for example:
##  Host foo
##    User bar
##    Port 1234
##    HostName 1.2.3.4
# Will allow using "foo" with the ssh command.
#
# Simple example usage:
##  # configure some variables
##  deploy_from="/path/to/working/copy"
##  deploy_to="somehost:/path/to/working/copy someuser@somehost:/path/to/"
##
##  # define a bash function which will be run on each servers
##  function your_deploy() {
##      # current directory is automatically set with $deploy_to
##      hg pull
##      sudo apache2ctl graceful
##  }
##
##  # deployment workflow
##  cd $deploy_from
##  hg push
##  remote your_deploy $deploy_to

# Runs a local function or remote command on one or several servers through ssh
# in given paths.
# For example, source this module and try:
##  # with a local function
##  function hello() { echo "Hello from `pwd`"; }
##  remote hello somehost: otherhost:/path/to/test
##  # with a remote command
##  remote "git pull origin master" somehost:/path
function remote() {
    local do="$1"
    shift
    local targets="$*"

    local target=""
    local target_host=""
    local target_path=""

    for target in $targets; do
        target_host="${target%%:*}"
        target_path="${target/$target_host:/}"

        if [[ -n "$(declare -f $do)" ]]; then
            mlog notice "Running $do() on $target_host in $target_path"
            ssh $target_host "cd $target_path && $(declare -f $do) && $do"
        else
            mlog notice "Running $do on $target_host in $target_path"
            ssh $target_host "cd $target_path && $do"
        fi
    done
}
