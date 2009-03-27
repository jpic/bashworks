#!/bin/bash
DEFAULT_CONFIG=".vcs.config.sh"

if [[ $config -eq "" ]]; then config="$DEFAULT_CONFIG"; fi
if [[ $ignore -eq "" ]]; then ignore=".gitignore"; fi
if [[ $master -eq "" ]]; then master="master"; fi
if [[ $prod -eq "" ]]; then prod="prod"; fi
if [[ $version -eq "" ]]; then version="0"; fi
if [[ $rc -eq "" ]]; then rc="0"; fi
if [[ $doc -eq "" ]]; then doc="DOCUMENTATION"; fi
if [[ $bug -eq "" ]]; then bug="BUGS"; fi
if [[ $objectives -eq "" ]]; then objectives=".todo.now"; fi
if [[ $state -eq "" ]]; then state="alpha"; fi
if [[ $feature -eq "" ]]; then feature="planning"; fi
if [[ $tag -eq "" ]]; then tag=""; fi
if [[ $readme -eq "" ]]; then readme="README"; fi
if [[ $backupdir -eq "" ]]; then backupdir="${HOME}/var/backups"; fi
if [[ $root -eq "" ]]; then root=""; fi
if [[ $logfile -eq "" ]]; then logfile=".logfile"; fi
# {{{ tag functions
# Usage: tag_update [<version number> [<state=$state> [<rc=$rc>] ] ]
#
# Sets $version, $state and $rc if supplied, and sets $tag by itself.
function tag_update() {
    if [[ $1 ]]; then version=$1; fi
    if [[ $2 ]]; then state=$2; fi
    if [[ $3 ]]; then rc=$3; fi

    if [[ $state ]]; then
        tag="${version}_${state}${rc}"
    else
        tag="${version}_${rc}"
    fi;
}
# Usage: tag [<commit> [<tag name>]]
#
# Sets $tag if supplied.
# Tags <commit> or the last commit.
function tag() {
    local snapshot=""
    if [[ $1 ]]; then snapshot=$1; fi
    if [[ $2 ]]; then tag=$2; fi
    git commit $tag $snapshot
}

# Usage: tag_rc [<rc>]
# 
# Sets $rc if supplied.
# Runs tag_update, then runs tag, then increment_rc
function tag_rc() {
    if [[ $1 ]]; then rc=$1; fi
    tag_update
    git tag $tag
    increment_rc
}

# Usage: tag_state [<state>]
# 
# Sets $state if supplied.
# Runs tag_update, then runs tag, then increments $state
function tag_state() {
    if [[ $1 ]]; then state=$1; fi
    tag_update
    git tag $tag
    increment_state
}

function tag_version()
{
    if [[ $1 ]]; then version=$version; fi
    tag_update
    git tag $tag
    increment_version
}
# }}}
# {{{ version, state, rc incrementers
function increment_version() {
    let version=$version+1
    echo $version
}

function increment_rc() {
    let rc=$rc+1
    echo $rc
}

function increment_state() {
    case "$state" in
        alpha)
            state="beta"
            ;;
        beta)
            state=""
            ;;
        *)
            state="alpha"
            ;;
    esac
    echo $state
}
# }}}
#{{{ shell vfunctions
# Usage: vcd
#
# Changes directory to $root
function vcd() {
    cd $root
}

# Usage: diff [<path0> [...<pathN>]]
#
# Wraps around your VCS diff command
function vdiff() {
    git diff $@
}
#}}}
# {{{ vcs wrappers
# Usage: initrepo [<path>]
#
# Overwrites $root with <path>, if specified.
# Sets it up for versionning.
function initrepo() {
    if [[ $1 ]]; then
        root=$1
    fi

    cd $root
    
    if [[ -d .git ]]; then
        return 0
    fi

    git init
    branch $master
    branch $prod

    return 0
}
# Usage: add <file0> [<file1> ... <fileN>]
#
# Adds the given files to the next commit
function add() {
    git add $@
}
# Usage: branch <branch_name>
#
# Checks out <branch_name>, creates it if it does not exist
function branch() {
    branch_exists $1
    
    if [[ $? -eq 0 ]]; then
        git checkout $1
    else
        git checkout -b $1
    fi
}

# Usage: branch_exists <branch name>
#
# Returns 0 if <branch name> exists, -1 otherwise.
function branch_exists() {
    if git branch | grep -q "${1}"; then
        return 0
    else
        return -1
    fi
}
function addi() {
    git add -i $@
}

# Usage: commit <message>
#
# Commits the changes with <message>
function commit() {
    echo $@ > $logfile
    git commit -F $logfile
}

# Usage: status
#
# Wraps around vcs status command
function status() {
    git status
}

# Usage: ignore <path|glob>
function ignore() {
    echo "$@" >> $ignore
}

function ecommit() {
    git commit $@
}
# }}}
## {{{ checking out, default branchings
# Usage: master
#
# Attempts to checkout master.
#
# Intended to come back from a branch (like prod).
function master() {
    branch $master
}
function prod() {
    branch $prod
}
function stash() {
    git stash
}
#}}}
# {{{ merging
function commit_to_prod() {
    prod
    git merge --squash $master
    master
}

function hist_to_prod() {
    prod
    git merge $master
    master
}

function unstash() {
    echo "Unstash your debug stuff? y<CR>"
    read confirm
    
    if [[ $confirm -eq 'y' ]]; then
        echo "Yes sir!"
        git stash apply
    fi
}
# }}}
# {{{ documenting
# Usage: readme
#
# Read critical investigation results
# Pipes $readme contents into $PAGER.
function readme() {
    cat $readme | $PAGER
}
# Usage: writeme
#
# Write critical investigation results
# Loads $readme with your favorite editor
function writeme() {
    $EDITOR $readme
}
# Read installation and maintenance investigation
function readbug() {
    cat $bug | $PAGER
}
# Write installation and maintenance investigation
function writebug() {
    $EDITOR $bug
}
# Read installation and maintenance investigation
function readdoc() {
    cat $doc | $PAGER
}
# Write installation and maintenance investigation
function writedoc() {
    $EDITOR $doc
}
# Read current session objective
function readobj() {
    cat $objectives | $PAGER
}
# Write current session objective
function writeobj() {
    $EDITOR $objectives
}
# }}}
#{{{ shell internal configuration database
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
        echo "updating $config"
    else
        echo "creating $config"
        echo "#!/bin/bash" > $config
        echo "" >> $config
    fi

    grep -q '^config="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@config=.*@config=\"$config\"@" $config
    else
        echo "config=\"$config\"" >> $config
    fi
    
    grep -q '^backupdir="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@backupdir=.*@backupdir=\"$backupdir\"@" $config
    else
        echo "backupdir=\"$backupdir\"" >> $config
    fi
    
    grep -q '^rc="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s/rc=.*/rc=\"$rc\"/" $config
    else
        echo "rc=\"$rc\"" >> $config
    fi
    
    grep -q '^ignore="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@ignore=.*@ignore=\"$ignore\"@" $config
    else
        echo "ignore=\"$ignore\"" >> $config
    fi

    grep -q '^master="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s/master=.*/master=\"$master\"/" $config
    else
        echo "master=\"$master\"" >> $config
    fi

    grep -q '^prod="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s/prod=.*/prod=\"$prod\"/" $config
    else
        echo "prod=\"$prod\"" >> $config
    fi

    grep -q '^version="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s/version=.*/version=\"$version\"/" $config
    else
        echo "version=\"$version\"" >> $config
    fi

    grep -q '^doc="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@doc=.*@doc=\"$doc\"@" $config
    else
        echo "doc=\"$doc\"" >> $config
    fi

    grep -q '^objectives="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@objectives=.*@objectives=\"$objectives\"@" $config
    else
        echo "objectives=\"$objectives\"" >> $config
    fi

    grep -q '^readme="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@readme=.*@readme=\"$readme\"@" $config
    else
        echo "readme=\"$readme\"" >> $config
    fi

    grep -q '^tag="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s/tag=.*/tag=\"$tag\"/" $config
    else
        echo "tag=\"$tag\"" >> $config
    fi

    grep -q '^state="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s/state=.*/state=\"$state\"/" $config
    else
        echo "state=\"$state\"" >> $config
    fi
    
    grep -q '^logfile="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@logfile=.*@logfile=\"$logfile\"@" $config
    else
        echo "logfile=\"$logfile\"" >> $config
    fi

    grep -q '^root="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@root=.*@root=\"$root\"@" $config
    else
        echo "root=\"$root\"" >> $config
    fi

    grep -q '^bug="[^"]*"$' $config
    if [[ $? -eq 0 ]]; then
        sed -i -e "s@bug=.*@bug=\"$bug\"@" $config
    else
        echo "bug=\"$bug\"" >> $config
    fi
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
# }}}

# Usage: starthacking [<path=`pwd`> [<config>]]
#
# Sets $root to <path>, changes directory to $root and runs load(config).
function starthacking() {
    if [[ $1 ]]; then
        root=$1
    else
        root=`pwd`
    fi

    if [[ -d $root ]]; then
        echo "Found $root";
    else
        echo "Create $root";
        mkdir -p $root
    fi

    cd $root

    if [[ $2 && -f $2 ]]; then
        load $2
    elif [[ -f $config ]]; then
        load $config
    else
        initrepo
        save
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
    echo "1) document: writedoc"
    echo "2) write critical stuff:              writeme"
    echo "3) write current objective:           writeobj"
    echo "4) add changes to index:              add fileFoo fileBar [...]"
    echo "          interactively:              addi"
    echo "5) commit with message:               commit Fixed bug foo"

    # Print navigation by default
    if [[ $1 != 1 ]]; then
        echo ""
        echo "Read this help at any time:           helpintro"
        echo "Read about commiting at any time:     helpcommit"
        echo ""
    fi
}

function helpcommit() {
    echo "Help about commiting"
    echo ""
    echo "You have two branches by default:"
    echo "- master: where you dev"
    echo "- prod: where you try to only push clean stuff"
    echo "You can switch from one to another with functions: master or prod"
    echo ""
    echo "Backup and reset working copy: stash"
    echo "Restore backed up stuff: unstash"
    echo ""
    echo "Merge master to prod"
    echo "  with full history:                  hist_to_prod"
    echo "  with last commit message:           commit_to_prod"

    # Print navigation by default
    if [[ $1 != 1 ]]; then
        echo ""
        echo "Read this help at any time:           helpcommit"
        echo "Read previous intro help at any time: helpintro"
        echo ""
    fi
}

helpintro 0
helpcommit 0

