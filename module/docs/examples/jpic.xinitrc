# i source this from xinitrc

# load the framework
source $1/module/source.sh

# find modules in my repo
module_repo $1

# load os_xrandr
module os_xrandr

# set the best resolution
os_xrandr_set_largest_output
