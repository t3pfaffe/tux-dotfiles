## Idle Locking Script

exec_idlehook() {
    nohup xidlehook --not-when-fullscreen --timer 450 "dunstify -r 99 -h string:x-dunst-stack-tag:lock-warn -a "xidlelock" -t 28000 -u normal 'LOCKING screen in 30 seconds...'" 'dunstify -C 99' --timer 30  'betterlockscreen -l blur' ''  --timer 1320 'systemctl suspend'  '' & disown
}

exec_xautolock() {
	xautolock -time 10 -secure -detectsleep -locker $exec_lock -notify 30 -notifier "$notify_critical 'LOCKING screen in 30 seconds..."	
}

check_running() {
	pgrep -x xidlehook && return 0 || return 1
}

notify_critical() {
    notify-send -i "/home/$USER/.config/i3/i3logo.png" -a "i3wm" -t 10000 -u critical "$1"
}

notify_low() {
     notify-send -i "/home/$USER/.config/i3/i3logo.png" -a "i3wm" -t 3000 -u low "$1"
}

# Supress command outputs
exec 1>/dev/null 2>&1

# Fallback if xidlehook is not installed
if ! command -v xidlehook
then
	echo "Command 'xidlehook' not found! falling back to 'xautolock'"
	exec_xautolock
	exit
fi

check_running && notify_low 'Restarting idlehook...'
pkill xidlehook
sleep 0.05
exec_idlehook
#nohup xidlehook --not-when-fullscreen --timer 450 "dunstify -r 99 -h string:x-dunst-stack-tag:lock-warn -a "xidlelock" -t 28000 -u normal 'LOCKING screen in 30 seconds...'" 'dunstify -C 99' --timer 30  'betterlockscreen -l blur' ''  --timer 1320 'systemctl suspend'  '' & disown
sleep 0.5
check_running || notify_critical "The autolocker xidlehook failed to start!"
