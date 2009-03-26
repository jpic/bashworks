#!/bin/bash
DEFAULT_CONFIG=".vcs.config.sh"

config=$DEFAULT_CONFIG
ignore=".gitignore"
master="master"
version="0.0"
rc="0"
state="alpha"
feature="planning"
fool="fooling_around"
readme="README"
root=""

# Usage: env_update
#
# Updates branch names variables depending on what you declared doing
function env_update() {
    if [[ $state ]]; then
        branch="${version}_${state}${rc}"
    else
        branch="${version}_${rc}"
    fi;
    
    feature_branch="${branch}_${feature}"
}

# Usage: branch_checkout_wrapper <branch_name>
#
# Checks out <branch_name>, creates it if it does not exist
function branch_checkout_wrapper() {
    if `branch_exists ${1}` == "true"; then
        git checkout $1
    else
        git checkout -b $1
    fi
}

function branch_exists() {
    if git branch | grep -q "${1}"; then
        echo "true"
    else
        echo "false"
    fi
}

# Usage: master_checkout
#
# Runs env_update and checks out $master
function master_checkout() {
    env_update
    branch_checkout_wrapper $master
}

# Usage: branch_checkout
#
# Runs master_checkout and checks out $branch
function branch_checkout() {
    master_checkout
    branch_checkout_wrapper $branch
}

# Usage: feature_checkout
#
# Runs branch_checkout and checks out $feature_branch
function feature_checkout() {
    branch_checkout
    branch_checkout_wrapper $feature_branch
}

# Usage: fool_checkout
#
# Runs feature_checkout and checks out $fool
# 
# The $fool branch commits will be squashed by passfool()
# The $fool branch is ideal to try a way to get $feature done
function fool_checkout() {
    feature_checkout
    branch_checkout_wrapper $fool
}

# Usage: add <file0> [<file1> ... <fileN>]
#
# Adds the given files to the next commit
function add() {
    git add $@
}

# Usage: commit <message>
#
# Commits the changes with <message>
function commit() {
    env_update
    git commit -m "$@"
}

# Usage: feature_merge [<message>]
#
# Runs branch_checkout and merges $feature_branch to $branch with <message>
# 
# This command is intended to be run once the current feature addition or
# changes are acceptable.
function feature_merge() {
    branch_checkout
    if [[ $@ ]]; then
        git merge -m "$@" $feature_branch
    else
        git merge $feature_branch
    fi
}

# Usage: branch_merge [<message>]
#
# Runs master_checkout and merges $branch_master to $master with <message>
# 
# This command is intended to be run once the current branch addition or
# changes are acceptable.
function branch_merge() {
    master_checkout
    if [[ $@ ]]; then
        git merge -m "$@" $branch
    else
        git merge $branch
    fi
}

# Usage: foolagain
#
# Runs feature_checkout, deletes branch $fool and re-creates it
#
# Intended to use when the last fooling around coding session cannot be
# acceptable to merge to $feature_branch
function foolagain() {
    feature_checkout
    if `branch_exists ${1}` == "true"; then
        git branch -D $fool
    fi
    branch_checkout_wrapper $fool
}

# Usage: passfool [<message>]
#
# Runs feature_checkout, merges $fool *squashing* $fool's commit log,
# with <message>
#
# If no message is specified, it adds $readme to the commit and
# specifies a default commit message, telling to check $readme
function passfool() {
    feature_checkout
    git merge --squash $fool

    if [[ $@ ]]; then
        git commit -m "$@"
    else
        add $readme
        git commit -m "Implemented $feature as described in $readme"
    fi
}

# Usage: readme
#
# Pipes $readme contents into $PAGER
function readme() {
    cat $readme | $PAGER
}

# Usage: writeme
#
# Loads $readme with your favorite editor
function writeme() {
    $EDITOR $readme
}

# Usage: save [<config file=$config>]
#
# Can overwrite $config
#
# Saves all our env variables to the config file
# Tryes to just overwrite variable values if the file exists
# Also sets $root to the current directory
function save() {
    if [[ $1 ]]; then
        config="$1"
    fi

    root=`pwd`

    if [[ -f $config ]]; then
        sed -i -e "s/config=.*/config=\"$config\"/" $config
        sed -i -e "s/ignore=.*/ignore=\"$ignore\"/" $config
        sed -i -e "s/master=.*/master=\"$master\"/" $config
        sed -i -e "s/version=.*/version=\"$version\"/" $config
        sed -i -e "s/rc=.*/rc=\"$rc\"/" $config
        sed -i -e "s/state=.*/state=\"$state\"/" $config
        sed -i -e "s/feature=.*/feature=\"$feature\"/" $config
        sed -i -e "s/fool=.*/fool=\"$fool\"/" $config
        sed -i -e "s/readme=.*/readme=\"$readme\"/" $config
        sed -i -e "s/root=.*/root=\"$root\"/" $config
    else
        echo "#!/bin/bash" > $config
        echo "" >> $config
        echo "config=\"$config\"" >> $config
        echo "ignore=\"$ignore\"" >> $config
        echo "master=\"$master\"" >> $config
        echo "version=\"$version\"" >> $config
        echo "rc=\"$rc\"" >> $config
        echo "state=\"$state\"" >> $config
        echo "feature=\"$feature\"" >> $config
        echo "fool=\"$fool\"" >> $config
        echo "readme=\"$readme\"" >> $config
        echo "root=\"$root\"" >> $config
    fi;
}

# Usage: load [<config file>]
#
# Loads a config file, which is determined in this order:
# - a config file path was specified to "load": use $1
# - $config is not "": use $config
# - use .vcs.config.sh
function load() {
    if [[ $1 ]]; then
        source $1
    elif [[ $config ]]; then
        source $config
    elif [[ -f $DEFAULT_CONFIG ]]; then
        source $DEFAULT_CONFIG
    else
        echo "Nothing to load"
        return -1
    fi

    if [[ `echo $PS1 | grep dev` ]]; then
        # Polite placeholder
        echo "Shell ready to conquer the world, dear master"
    else
        echo "$config loaded"
        PS1="(dev) $PS1"
    fi
}

# Usage: starthacking [<path=`pwd`> [<config>]]
#
# Sets $root to <path>, changes directory to $root and runs load(config).
function starthacking() {
    if [[ $1 ]]; then
        root=$1
    else
        root=`pwd`
    fi

    cd $root

    if [[ $2 ]]; then
        load $2
    else
        load $config
    fi
}

# Usage: helpintro [<hide navigation>]
#
# Shows introduction help and displays navigation within help
# if <hide navigation> is not 1.
function helpintro() {
    echo "Hack somewhere"
    echo ""
    echo "0) starthacking /foo/bar: starthacking /foo/bar"

    # Print navigation by default
    if [[ $1 != 1 ]]; then
        echo ""
    fi
}

helpintro
