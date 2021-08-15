#!/bin/bash
# sensible-xbright Script:
#   location: ~/.config/i3/scripts/sensible-xbright.sh
#   author: t3@pfaffe.me    🄯2020-01.05.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )

#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.


#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Common function definitions.


#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

## TODO: migrate display brightness cmds here

## Monitor Brightness Controls:
# bindsym XF86MonBrightnessUp     exec --no-startup-id light -A 5 && $notify_low -h string:x-dunst-stack-tag:XF86brightness -a "light" -t 750 "Brightness: $(light -G)"
# bindsym XF86MonBrightnessDown   exec --no-startup-id light -U 5 && $notify_low -h string:x-dunst-stack-tag:XF86brightness -a "light" -t 750 "Brightness: $(light -G)"


#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.


#
# FILE_END
