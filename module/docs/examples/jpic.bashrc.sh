# i source this from .bashrc

# load the framework
source $HOME/src/bashworks/module/source.sh

# find modules in my repo
module_repo $HOME/src/bashworks

# load core modules
module conf mlog hack

# load conf_auto
module conf_auto
# load configuration of conf_auto
conf_load conf_auto
# load all configurations i wanted saved
conf_auto_load_all

# load os_home
module os_home
# prepare home with os-specific builds
os_home_symlink
