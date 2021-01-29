#!/bin/bash
# sensible-xidlelock Script:
#   location: ~/.config/i3/scripts/sensible-xidlelock.sh
#   author: t3@pfaffe.me    🄯2020-01.05.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

# Define lock timers
# time_lock=450
time_lock=5
time_suspend=1320



## Lock wrapper
exec_lock=~/.config/i3/scripts/sensible-xlock.sh

## Lock Text
lock_text="-t 'Entered idle-lock...' "

#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Function definitions.

## Utilities:
#############
check_running() {
	pgrep -x xidlehook >/dev/null && return 0 || return 1
}

notify_critical() {
    notify-send -i "/home/$USER/.config/i3/i3logo.png" -a "i3wm" -t 10000 -u critical "$1"
}

notify_low() {
     notify-send -i "/home/$USER/.config/i3/i3logo.png" -a "i3wm" -t 3000 -u low "$1"
}
#############

## Script Functions:
####################
## Display help
show_usage() {
    printf "Usage: sensible-xidlelock [OPTIONS]"

    printf "\n\nRuns preferred idle-lock applications with fail-over."

    #Show options/parameters
    printf "\n"
    printf "\nOptions: "
    printf "\n  -h, --help \n\t\tShow this message and exit."

    #End statement
    printf "\n"
}

## Warn that lock is soon
warn_lock="dunstify -r 99 -h string:x-dunst-stack-tag:lock-warn -a xidlelock -t 28000 -u normal 'LOCKING screen in 30 seconds...'"
clr_warn_lock="dunstify -C 99"

## Primary idle-lock option
exec_idlehook() {
    nohup xidlehook --not-when-fullscreen --timer $time_lock "$warn_lock" "$clr_warn_lock" --timer 30 "${exec_lock} ${lock_text}" '' --timer $time_suspend 'systemctl suspend' '' & disown
    # xidlehook --not-when-fullscreen --timer $time_lock "$warn_lock" "$clr_warn_lock" --timer 30 "${exec_lock} ${lock_text}" '' --timer $time_suspend 'systemctl suspend' ''
}

## Backup idle-lock option
exec_xautolock() {
	xautolock -time $time_lock -secure -detectsleep -locker $exec_lock -notify 30 -notifier "$warn_lock"	
}
####################

#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

## Check for additional parameters
for i in "$@"
do
case $i in
    -h|--help)
        show_usage; exit 0
    ;;
    *)
    ;;
esac
done

# Supress command outputs
# exec 1>/dev/null 2>&1

# Fallback if xidlehook is not installed
if ! command -v xidlehook >/dev/null
then
	echo "Command 'xidlehook' not found! falling back to 'xautolock'"
	exec_xautolock && exit 0 || exit 1
fi

check_running && notify_low 'Restarting idlehook...'
pkill xidlehook >/dev/null
sleep 0.05
exec_idlehook

#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.

## Check if it crashed/failed to start:
sleep 0.5 ; check_running || notify_critical "The autolocker xidlehook failed to start!"


#
# FILE_END