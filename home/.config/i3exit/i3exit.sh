#!/bin/sh
# i3exit User Script:
#   location: ~/.config/i3exit/i3exit.sh
#   author: t3@pfaffe.me    🄯2020-01.31.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )


## Change System session method if on openrc instead of systemd
[ "$(cat /proc/1/comm)" = "systemd" ] && logind=systemctl || logind=loginctl

SRC_XLOCK_SCRIPT=~/.config/i3/scripts/sensible-xlock.sh

## Tries locking the xsession with a screensaver:
##  failsover in preferential order.
try_lock () {
    $SRC_XLOCK_SCRIPT --lock && return 0                #0
    betterlockscreen -l dimblur >/dev/null && return 0  #1
    i3lock -i "$WALLPAPER" >/dev/null && return 0       #2
    xscreensaver -lock >/dev/null && return 0           #3
    return 1 # Give up
}

case "$1" in
    lock)
        try_lock
        ;;
    logout)
        i3-msg exit
        ;;
    switch_user)
        dm-tool switch-to-greeter
        ;;
    suspend)
        try_lock && $logind suspend
        ;;
    hibernate)
        try_lock && $logind hibernate
        ;;
    reboot)
        $logind reboot
        ;;
    shutdown)
        $logind poweroff
        ;;
    *)
        echo "== ! i3exit: missing or invalid argument ! =="
        echo "Try again with: lock | logout | switch_user | suspend | hibernate | reboot | shutdown"
        exit 2
esac

exit 0
