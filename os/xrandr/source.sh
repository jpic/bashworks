os_xrandr_displays=()

# Resets xrandr variables and parses xrandr output.
function os_xrandr_post_load() {
    os_xrandr_reset
    os_xrandr_parse
}

# Parses xrandr modes into bash lists.
# It will parse the output of `xrandr` and declare one variable per screen,
# like $xrandr_modes_VGA1. Each of this variables is an array of avalaible
# modes for this display. 
# For example:
##  echo ${os_xrandr_modes_VGA1[@]} 
##  1280x1024 1280x1024 1024x768 832x624 800x600 640x480 720x400
function os_xrandr_parse() {
    local current_modes=""
    
    # extract
    local results="$(xrandr | grep -o -e '\([A-Z]\+[0-9]\+ connected\)\|\([0-9]\+x[0-9]\+  \)')"

    # parse
    for result in $results; do
        if [[ $result =~ connected ]]; then
            continue
        fi

        if [[ $result =~ [A-Z] ]]; then
            current_modes="os_xrandr_modes_${result}"
            eval "$current_modes=()"
            os_xrandr_displays+=("$result")
        else
            eval "$current_modes+=(\"$result\")"
        fi
    done
}

# Reset xrandr variables
function os_xrandr_reset() {
    # reset
    for display in ${os_xrandr_displays[@]}; do
        unset "os_xrandr_modes_${display}"
    done

    os_xrandr_displays=()
}

# Given a display name, it will output the largest mode.
# For example:
##  os_xrandr_largest_mode VGA1 # will output:
##  1280x1024
function os_xrandr_largest_mode() {
    eval "echo \$os_xrandr_modes_$1"
}

# Outputs the name of the display that is capable of the largest mode.
function os_xrandr_largest_display() {
    local largest=""
    local -i largest_width=0
    local -i width=0
    local tmp=""

    for display in $os_xrandr_displays; do
        tmp="$(os_xrandr_largest_mode $display)"
        local -i width=${tmp%%x*}
        if [[ $width -gt $largest_width ]]; then
            local -i largest_width=$width
            largest="$display"
        fi
    done

    echo $display
}

# Uses xrandr to set the largest mode to the largest display.
function os_xrandr_set_largest_output() {
    xrandr --output $(os_xrandr_largest_display) --mode $(os_xrandr_largest_mode `os_xrandr_largest_display`)
}
