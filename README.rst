Who said "temporary (bash) scripts"? Not me.

0.4 beta 0 documentation
~~~~~~~~~~~~~~~~~~~~~~~~

Introduction
============

This bash framework is different from other bash frameworks:

- KISS (no black magic such as: attempt to imitate OOP, "smart" code),
- encourages agile development in decoupled modules,
- makes use of the bash shell: you don't have to make scripts with it,
- code sharing,

Requirement
===========

Bash 4.x is required.

Quick start
===========

The Quick Start chapter guides you through testing the framework, step by step,
without you having to install anything, particularely not in any directory
outside your home. Of course, it doesn't take any shortcut, allowing the reader
to understand more of what is going on - which is hopefully simple.

The installation guide is the next chapter.

Start bash and do::

    git clone git://github.com/jpic/bash-framework.git
    source /path/to/your/clone/module.sh /path/to/your/clone
    module

Details
-------

The clone sources contain a module.sh file which is the actual framework base,
it contains the lowest level inversion of control logic provided. It also
contains several directories, each correspond to a module. Some contain sub
directories which are submodules.

source /path/to/your/clone/modules.sh loads the functions of modules.sh in the
current shell, it can take several paths to module repositories. Module
repositories are directories which contain module directories.  Note that it
will use the environment variable MODULES_PATH as well if it is defined.
MODULES_PATH environment variable is expected to be set with the same format
the PATH environment variable uses. For example::

    MODULES_PATH="/path/to/jpic/repo:/path/to/your/repo".

module() is a function defined by modules.sh, it basically it loads all modules
it could find.

If anything goes wrong then it is possible to read the source of this function
with declare -f, and the documentation either online or in the docs directory,
and run parts of it one by one in your shell. This is the general debugging
procedure, knowing it will probably be more usefull when developing your own
modules.

Setup your module
-----------------

Because this bash framework encourages modular development for best reusability
of your work::

    # create a directory for your repo
    mkdir ~/yourrepo
    
    # create a module
    mkdir ~/yourrepo/hello
    touch ~/yourrepo/hello/source.sh

    # make module.sh read your repo
    module ~/yourrepo

    # Calling module_get_path() should output the path of your repo
    module_get_path hello

Source.sh
---------

Any directory in a repo dir which contains a source.sh file is useable as a
module. By default, source.sh doesn't need anything, but can contain some quite
useful stuff.

If your module depends on the environment, be it variables or installed
software, then the _pre_source() function should be defined. For example, in
mtests/shunit/source.sh::

    function mtests_shunit_pre_source() { 
        export SHUNIT_HOME="$(module_get_path mtests_shunit)/current"
    }

The _pre_source() function can also test the system and determine if it
provides the commands it needs to run properly. If the _pre_source() function
determines that the system is unable to operate the module then it can call
function module_blacklist_add(). The module.sh script uses function
module_blacklist_check() to determine if it should continue loading modules.

When module.sh ran the _pre_source() function of all modules: it runs the
_source() function of all modules. The _source() function's role is to load all
dependencies, it may use the module_get_path() function, for example, in
conf/source.sh::

    function conf_source() {
        source $(module_get_path conf)/functions.sh
        source $(module_get_path conf)/module.sh
    }

When module.sh is done calling the _source() function of all modules then it
starts calling the _post_source() function of each module, which is again
optionnal. This function is the last chance for the module to be prepared to
work as expected by the user. It is also the last relevant chance to use
module_blacklist_add(). For example, in break/source.sh::

    function break_post_source() {
        # set a default
        break_interval=7200

        # prepare for the conf module
        break_conf_path="${HOME}/.break"
    }

Proposed application layout
---------------------------

It is suggested to keep the module control functions in source.sh, the
functions in functions.sh, and use any other module name for the file that will
declare functions that actually tie the other module in question. For example,
the vps module overloads some conf defaults, see vps/conf.sh::

    function vps_conf_interactive() {
        unset vps_ip
        unset vps_intranet
        unset vps_host_ip
    
        conf_interactive vps

        # call the module specific function to configure the network
        vps_conf_interactive_network
    }

Proposed development workflow
-----------------------------

If you are clueless about software design, test first development, or just want
to get something done quick and right:

- create the module directory,
- start working in source.sh,
- test directly in the bash shell,
- move functins from source.sh to other files or submodules if relevant,
- eventually make a bash script,

This modular framework architecture is pretty easy to get and you'll be able to
make relevant modular designs eventually pretty fast.

Installation
============

Framework
---------

- export MODULE_PATH with the module repo paths you want,
- call source module.sh in .bashrc,
- call module() in .bashrc,

Note: MODULE_PATH environment variable takes a list of paths to directories
containing one or several modules separated by *:*.

Configuration
-------------

To configure a module, call `conf modulename`. Don't forget to configure the configuration automagic module with `conf conf_auto`.

It will propose to append a call to conf_auto_load_all to your .bashrc and conf_auto_save_all to your .bash_logout if it is not there.

Standards
=========

Namespacing
-----------

Each module declare functions and variables which name are prefixed with the
module name and an underscore. For example, all variable and function names of
the "volume" module are prefixed by "volume\_".

Main function
-------------

Optionnaly, a module may have a function which name is the same as the module.

For example the "mtests" module declares a "mtests()" convenience function
which takes a module name as parameter and run all tests in the given module.

Polite functions
----------------

Generic reuseable functions usually take a module name string argument. It
should let the actual module to overload what is it about to process.

For example, conf_save() is polite, calling `conf_save yourmodule` will first
check if yourmodule_conf_save() exists, and run it then return 0 if it does.

"Civilized coding" sucks way less than reinventing OOP in Bash.

Configuration module
====================

The configuration module declares functions to update, save and load variables.

The functions that take a module name as argument are in conf/module.sh, which
basically wraps around the actual functions in conf/functions.sh. Functions you
want to use are most likely defined and documented in conf/module.sh.

Test module
===========

The test module declares a function taking a module name as parameter: mtest().
This function runs all tests of a module. All frameworks are supported:

- bashunit,
- shunit,
- shunit2.

Module loading
==============

The module.sh script takes care of managing modules loading, and defines
utility functions concerning those loaded modules, ie. module_blacklist_add(),
module_blacklist_check(), module_get_path().

It supports several modules repository as well as submodules.

Module repositories
===================

A module repository is a directory which contains one or several module
directories. It can be specified in the MODULE_PATH environment variable, just
the same way the PATH variable is defined: with a list of paths separated by :.

Submodules
==========

A submodule is a module located inside another module that depends on it. There
is no submodule nesting level restriction, but the namming standard is
*slightly* different, consider the following example table:

=========== =========== =========
Module      Path        Prefix
=========== =========== =========
vcs         /vcs        vcs\_
vcs_git     /vcs/git    vcs_git\_
vcs_svn     /vcs/svn    vcs_svn\_
=========== =========== =========

Credit
======

bashunit, shunit and shunit2.

\#bash@irc.freenode.net: very very nice and knowledgeable users...

All Open Source hackers. Thanks a bunch for your involvement!

Versions
========

0.4_beta2
    Acceptable documentation

0.4_beta1
    Conf_auto module.

0.4_beta0
    Finnaly sorted the general architecture.

0.4_alpha1
    Test break

0.4_alpha0
    "remove 50% of code" refactor

0.3_alpha0
    major refactor

0.2_alpha5
    convenient interactive module configuration UI: conf_module()

0.2_alpha4
    simple demonstration music module

0.2_alpha3
    simple demonstration volume control module

0.2_alpha2
    os management module basics

0.2_alpha1
    configuration module (part that was decoupled) with a simple

0.2_alpha0
    bootstrap script

0.1_beta0
    vps.sh: everything seems to work, freezing vps\_ api

0.1_alpha2
    vps.sh: vps_ssh works

0.1_alpha1
    vps.sh: tested/fixed vps stuff except ssh
    vps.sh: portage shortcuts

0.1_alpha0
    new extension: vps.sh all functions and variablesprefixed by vps\_
    wifi.sh: bugfix, added reload function, stable.
    vcs.sh: regenerate $tag on load, stable.

0_alpha1
    new extension: vcs.sh

0_alpha0
    what i and kore cracked wep keys with

Author
======

James Pic <jamespic@gmail.com>
