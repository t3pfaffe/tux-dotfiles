#!/bin/bash
# bash_logout Config File:
#   location:~/.bash_logout
#   author: t3@pfaffe.me  🄯2020-01/05/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Bash script executed on login-shell's exit.



###############################
### INITIALIZE_BASH_LOGOUT: ###############################################
###############################

## Tag self as linked for dependents:
# shellcheck disable=2034
HAS_BASH_PROFILE=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Define goodbye message
print_goodbye_msg () {
    local currentTime cmd_pid elapsedTime

    cmd_pid=$BASHPID
    currentTime="$(date +%m/%d/%C) $(date +%H:%M)"
    elapsedTime=$(ps -p $cmd_pid -o etime | sed -n -e '2s/^[ \t]*//p')

    printf "(Session Elapsed %s) Goodbye! - %s \n" "$elapsedTime" "$currentTime"
}


##############################
### CLOSE_UP_BASH_SESSION: ################################################
##############################

# Show goodbye message
trap print_goodbye_msg EXIT


#
## END_FILE
