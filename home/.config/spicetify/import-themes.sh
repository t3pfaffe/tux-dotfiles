#!/bin/sh
# $SCRIPT_NAME Script:
#   location: ~/Documents/Scripts/Public/$SCRIPT_NAME.sh
#   author: t3@pfaffe.me    🄯2020-01.05.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

printf 'Attempting to copy over themes to local user directory...'
cp -r /usr/share/spicetify-cli/Themes/* ~/.config/spicetify/Themes/
cp -r /usr/share/spicetify-cli/Extensions/* ~/.config/spicetify/Extensions/

#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Common function definitions.


#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

#printf 'This is an example script. For demonstration purposes...\n'
#printf '	the current system time is %s \n' "$START_TIME $TIME_ZONE"

#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.


#
# FILE_END
