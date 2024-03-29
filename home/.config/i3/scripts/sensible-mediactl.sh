#!/bin/bash
# Sensible-MediaCtl Script:
#   location: ~/.config/i3/scripts/sensible-mediactl.sh
#   author: t3@pfaffe.me    🄯2020-04.05.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Abstractly controls media(mpris) &
#       available sound server settings.
#    - Other notes/references:
#       - [link]( https://github.com/t3pfaffe )


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

# Define this script's name
SCRIPT_NAME="sensible-mediactl"

SYMB_MEDIA_NOTE="♪♪"
SYMB_MEDIA_PLAY="▶"
SYMB_MEDIA_PAUSE="="
SYMB_MEDIA_STOP="■"

PLAYERCTL_SELECTED "spotify"

MEDIA_INFO=""
MEDIA_INFO_LONG=""

#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Common function definitions.

xml_escape() {
	local JSON_TOPIC_RAW="$1"
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\\/\\\\}		# \
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\//\\\/}		# /
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\"/\\\"}		# "
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//   /\\t}		# \t     (tab)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW///\\\n}		# \n     (newline)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^M/\\\r}		# \r     (carriage return)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^L/\\\f}		# \f     (form feed)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^H/\\\b} 	# \b     (backspace)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//&/\&#038;}	# &#038; (ampersand)
	echo "$JSON_TOPIC_RAW"
}

## TODO: migrate i3status-wrapper's media info to this
pollMediaInfoUpdate() {

    local STATUS MEDIA_TITLE MEDIA_ARTIST MEDIA_STATE

	#Pull Media Info
	STATUS="$(playerctl --player=spotify,%any status || echo "null")"
	if [ "$STATUS" = "null" ]; then
		MEDIA_INFO=""; MEDIA_INFO_LONG=""; return 0
    fi

	MEDIA_TITLE="$(playerctl --player=spotify,%any metadata title)"
    MEDIA_ARTIST="$(playerctl --player=spotify,%any metadata artist)"
    MEDIA_STATE=""
	##

	if [ "$STATUS" = "Playing" ]; then
                MEDIA_STATE="$SYMB_MEDIA_PLAY"
        elif [ "$STATUS" = "Paused" ]; then
                MEDIA_STATE="$SYMB_MEDIA_PAUSE"
	else
		MEDIA_STATE="$SYMB_MEDIA_STOP"
	fi

	MEDIA_TITLE=$(xml_escape "$MEDIA_TITLE")
	MEDIA_ARTIST=$(xml_escape "$MEDIA_ARTIST")

	MEDIA_PREPEND="$SYMB_MEDIA_NOTE($MEDIA_STATE)"
	MEDIA_INFO="$MEDIA_PREPEND - $MEDIA_TITLE "
	MEDIA_INFO_LONG="$MEDIA_PREPEND $MEDIA_TITLE - $MEDIA_ARTIST "
}

## TODO: make this responsively update fromf Playerctl with follow
followMediaInfoUpdate() {

    local STATUS MEDIA_TITLE MEDIA_ARTIST MEDIA_STATE

	#Pull Media Info
	STATUS="$(playerctl --player=${PLAYERCTL_SELECTED},%any status || echo "noPlayers")"
	if [ "$STATUS" = "noPlayers" ]; then
		MEDIA_INFO=""; MEDIA_INFO_LONG=""; return 0; fi

	MEDIA_TITLE="$(playerctl --player=${PLAYERCTL_SELECTED},%any metadata title)"
    MEDIA_ARTIST="$(playerctl --player=${PLAYERCTL_SELECTED},%any metadata artist)"
    MEDIA_STATE=""
	##

	if [ "$STATUS" = "Playing" ]; then
                MEDIA_STATE="$SYMB_MEDIA_PLAY"
        elif [ "$STATUS" = "Paused" ]; then
                MEDIA_STATE="$SYMB_MEDIA_PAUSE"
	else
		MEDIA_STATE="$SYMB_MEDIA_STOP"
	fi

	MEDIA_TITLE=$(xml_escape "$MEDIA_TITLE")
	MEDIA_ARTIST=$(xml_escape "$MEDIA_ARTIST")

	MEDIA_PREPEND="$SYMB_MEDIA_NOTE($MEDIA_STATE)"
	MEDIA_INFO="$MEDIA_PREPEND - $MEDIA_TITLE "
	MEDIA_INFO_LONG="$MEDIA_PREPEND $MEDIA_TITLE - $MEDIA_ARTIST "
}

show_usage() {
    printf "Usage: %s [OPTIONS]" "$SCRIPT_NAME"

    printf "\n\nBase template for shell scripts. This is an example script for example purposes."

    #Show options/parameters
    printf "\n"
    printf "\nOptions: "
    printf "\n  -h, --help \n\t\tShow this message and exit."

    #End statement
    printf "\n"
}


#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

## Check for parameters/options:
if [ $# -eq 0 ] ; then ## Default behaviour with no args:
    printf ""
    ## Un-comment below if script requires an argument to function
    #show_usage; exit 0
else
    for i in "$@" ; do
        case $i in
            -h|--help)
                show_usage; exit 0
            ;;
            *-[!\ ]*)
                printf "%s: invalid option '%s'\n" "$SCRIPT_NAME" "$1"
                printf "Try '%s --help' for more information.\n" "$SCRIPT_NAME"
                shift; exit 1
            ;;
        esac
    done
fi



#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.


#
# FILE_END
