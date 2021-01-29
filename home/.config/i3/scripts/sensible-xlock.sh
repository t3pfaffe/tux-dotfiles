#!/bin/bash
# sensible-xlock Script:
#   location: ~/.config/i3/scripts/sensible-xlock.sh
#   author: t3@pfaffe.me    🄯2020-01.05.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

# Default lock screen text
lock_text="Type password to unlock..."


#######################
### BASH_UTILITIES: #######################################################
#######################

## 'str_empty' - Checks if provided string(s) exist(s):
## usage: str_empty <variable_name>
######################################################
str_empty () {
    for arg in "$@" ; do [[ -z "${arg// }" ]] || return 1 ; done ; return 0
}
######################################################
## 'var_exists' - Checks if provided variable(s) exist:
## usage: var_exists <variable_name>
###################################################
var_exists () {
    str_empty "$1" && return 1
    for arg in "$@" ; do declare -p "$arg" &>/dev/null || return 1 ; done ; return 0
}
## 'cmd_exists' - Checks if provided command(s) exist:
## usage: cmd_exists <cmd>
######################################################
cmd_exists () {
    str_empty "$1" && return 1
    for arg in "$@" ; do command -v "$arg" >/dev/null || return 1 ; done ; return 0
}
## 'file_exists' - Checks if provided file(s) exist:
## usage: file_exists <file_path>
###################################################
file_exists () {
    str_empty "$1" && return 1
    for arg in "$@" ; do [ -f "$arg" ] >/dev/null || return 1 ; done ; return 0
}


#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Function definitions.

show_usage() {
    printf "Usage:  [OPTIONS]"

    printf "\n\nRuns preferred lock applications with fail-over."

    #Show options/parameters
    printf "\n"
    printf "\nOptions: "
    printf "\n  -h, --help \n\t\tShow this message and exit."
    printf "\n  -i --initialize	\n\t\tRuns any chaching/setup reccomened prior to lock at startup."
       printf "\n  -l --lock \n\t\tExecutes lock cmds."
    printf "\n  -t --text= \n\t\tSets custom text for the lock screen."


    #End statement
    printf "\n"
}

find_avail_lock () {
    cmd_exists betterlockscreen && echo 0 && return 0
    cmd_exists i3lock           && echo 1 && return 0
    cmd_exists xscreensaver     && echo 2 && return 0
    cmd_exists cinnamon-screensaver-command && echo 3 && return 0
    # None available
    return 1
}

betterlockscreen_lock() {
    betterlockscreen -l dimblur -t "$lock_text" >/dev/null && return 0 || return 1
}

i3lock_lock() {
    str_empty "$lock_text" || i3lock -i "$WALLPAPER" --locktext="$lock_text" >/dev/null && return 0 || return 1
}

init_try_lock () {
    local avail=""
    avail=$(find_avail_lock) || return 1
    
    case $avail in
        0)
            if file_exists "$WALLPAPER"; then
                betterlockscreen -u "$WALLPAPER" -b 2 && return 0; fi
                betterlockscreen -u >/dev/null && return 0 || return 1
        ;;
    esac 
}

set_lock_text(){
    local args=""; args="$*"
    if ! str_empty "$args" ; then
        lock_text=$args
        lock_requested=true
        return 0
    fi
    return 1
}

## Try prefered lock command & fail-over if failed:
try_lock () {
    ## TODO: use $lock_text if possible.
    betterlockscreen_lock && return 0                       #0
    i3lock_lock && return 0                                 #1
    xscreensaver -lock >/dev/null && return 0               #2
    cinnamon-screensaver-command -l >/dev/null && return 0  #3
    # Give up
    return 1	
}


#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

# ## Check for null arguments
# if [[ $# -eq 0 ]] ; then
#     try_lock
# fi

# Whether or not a lock is requested in parameters
lock_requested=false

## Check for parameters/options:
if [[ $# -eq 0 ]] ; then
    ## Default behaviour with no args is to lock:
    lock_requested=true
else
    ## Check for additional parameters:
    for i in "$@"
    do
    case $i in
        -h|--help)
            show_usage ; exit 0
        ;;
        -i|--initialize)
            init_try_lock
            shift
        ;;
        -l|--lock)
            lock_requested=true
            shift
        ;;
        --text=*)
            set_lock_text "${i#*=}"
            shift
        ;;
        -t)
            set_lock_text "$2"
            shift 2
        ;;
        *)
            str_empty "$1" || ( echo "Warning ${1} not a valid parameter!" ; exit 1 )
        ;;
    esac
    done
fi 

# Run locking cmd
$lock_requested && ( try_lock && exit 0 || exit 1 )

#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.

exit 0

#
# FILE_END
