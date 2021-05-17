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



#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Common function definitions.

report() {
	status=$?
	case "$status" in
		0)
			printf '\n done!'; exit 1
		;;
		1)
			printf '\n failed!'; exit 0
		;;
        esac
}

try_permissions() {
	# Ensure correct permissions for spicetify to be able to access:
	printf 'Setting directory permissions...'
	sudo chmod a+wr /opt/spotify && sudo chmod a+wr /opt/spotify/Apps -R && report 0 || report 1
}

try_symlink() {
	printf 'Attempting to symlink root themes dir to local user directory...'
	report ln -s /usr/share/spicetify-cli/Themes/* ~/.config/spicetify/
	printf 'Attempting to symlink root extensions dir to local user directory...'
	report ln -s /usr/share/spicetify-cli/Extensions/* ~/.config/spicetify/
}

try_copy() {
	printf 'Attempting to copy root themes dir to local user directory instead...'
	report cp -r /usr/share/spicetify-cli/Themes/* ~/.config/spicetify/Themes/
	printf 'Attempting to copy root extensions dir to local user directory instead...'
	report cp -r /usr/share/spicetify-cli/Extensions/* ~/.config/spicetify/Extensions/
}

#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

try_permissions

try_symlink


#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.


#
# FILE_END
