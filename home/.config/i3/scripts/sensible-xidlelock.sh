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

## Define lock timers (seconds):
T_WARN=30
T_LOCK=450
T_SUSPEND=1320

## Define unique notif ID:
NOTIFS_ID="949291"

## Runtime parameters:
lockscreen_text="-t 'Entered idle-lock...' "
force_restart=false


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
    printf "\n  -f, --force \n\t\tForce a restart of the daemon."

    #End statement
    printf "\n"
}

# Comman to run lockscreen script
exec_lock=~/.config/i3/scripts/sensible-xlock.sh

# Command to Notify with a warning that a idle screen lock is eminent
exec_idle_warn="dunstify -r ${NOTIFS_ID} -h string:x-dunst-stack-tag:lock-warn -a xidlelock -t 28000 -u normal 'LOCKING screen in 30 seconds...'"

# Command to clear idle screen warnings
exec_clr_warn="dunstify -C ${NOTIFS_ID}"

## Primary idle-lock option
exec_idlehook() {
    nohup xidlehook --not-when-fullscreen --timer $T_LOCK "$exec_idle_warn" "$exec_clr_warn" --timer $T_WARN "${exec_lock} ${lockscreen_text}" '' --timer $T_SUSPEND 'systemctl suspend' '' &
    disown
}

## Backup idle-lock option
exec_xautolock() {
    xautolock -time $T_LOCK -secure -detectsleep -locker $exec_lock -notify $T_WARN -notifier "$exec_idle_warn"
}
####################


#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

## Check for additional parameters:
for i in "$@"; do
    case $i in
    -h | --help)
        show_usage
        exit 0
        ;;
    -f | --force)
        force_restart=true
        ;;
    *[!\ ]*)
        echo "Warning ${1} not a valid parameter!"
        shift
        ;;
    esac
done

## Supress futher command outputs
exec 1>/dev/null 2>&1

## Failover if xidlehook is not installed
if ! command -v xidlehook >/dev/null; then
    echo "Command 'xidlehook' not found! falling back to 'xautolock'"
    exec_xautolock && exit 0 || exit 1
fi

## Ensure that a singleton idlelock daemon is running:
if check_running; then
    if $force_restart; then     # Force restarting; killing any existing daemon.
        notify_low 'Restarting idlehook...'
        pkill xidlehook >/dev/null
        sleep 0.05
        exec_idlehook
    else
        exit 1                  # Do nothing bc another instance of the daemon is already running
    fi
else
    exec_idlehook # Start a new instance of the idlehook daemon
fi


#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.

## Check if it crashed/failed to start:
sleep 0.5
check_running || notify_critical "The autolocker xidlehook failed to start!"


#
# FILE_END
