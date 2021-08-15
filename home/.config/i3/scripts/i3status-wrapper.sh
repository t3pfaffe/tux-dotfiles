#!/bin/bash
# shell script to prepend i3Status with mediaInfo


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

## Runtime params:
FOLLOW_PLAYERCTL=false
PLAYERCTL_SELECTED "spotify"

## Symbolic glyphs used:
SYMB_MEDIA_NOTE="♪♪"
SYMB_MEDIA_PLAY="⏵"
SYMB_MEDIA_PAUSE="="
SYMB_MEDIA_STOP="■"

## Parsed info buffer vars:
MEDIA_INFO=""
MEDIA_INFO_SHORT=""


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

pollMediaInfoUpdate() {

    local STATUS MEDIA_ARTIST_TITLE MEDIA_STATE

	#Pull Media Info
	STATUS="$(playerctl --player=spotify,%any status || echo "null")"
	if [ "$STATUS" = "null" ]; then
		MEDIA_INFO=""; MEDIA_INFO_LONG=""; return 0
    fi

    MEDIA_ARTIST_TITLE="$( playerctl metadata --format '{{ markup_escape(artist) }} - {{ markup_escape(title) }}' )"

    if [ "$STATUS" = "Playing" ]; then
        MEDIA_STATE="$SYMB_MEDIA_PLAY"
    elif [ "$STATUS" = "Paused" ]; then
        MEDIA_STATE="$SYMB_MEDIA_PAUSE"
    else
		MEDIA_STATE="$SYMB_MEDIA_STOP"
	fi

	MEDIA_PREPEND="$SYMB_MEDIA_NOTE($MEDIA_STATE)"
	MEDIA_INFO="$MEDIA_PREPEND $MEDIA_ARTIST_TITLE "

	#MEDIA_INFO_SHORT="$MEDIA_PREPEND - $MEDIA_TITLE "
    MEDIA_INFO_SHORT="$MEDIA_INFO"
}

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


#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

i3status | (read -r line && echo "$line" && read -r line && echo "$line" && read -r line && echo "$line" && pollMediaInfoUpdate && while :
do
	if $FOLLOW_PLAYERCTL ; then
        read -r line
    else
        read -r line && pollMediaInfoUpdate
    fi

	#Format MEDIA_INFO for i3Status XML
	MEDIA_LINE="{\"name\":\"media_info\",\"markup\":\"pango\",\"border_bottom\":3,\"separator_block_width\":3,\"align\":\"right\",\"short_text\":\"${MEDIA_INFO_SHORT}\",\"full_text\":\"${MEDIA_INFO}\"}"

	echo ",[${MEDIA_LINE},${line#,\[}" || echo "$line" || exit 1

done)


#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.

unset MEDIA_INFO MEDIA_INFO_LONG FOLLOW_PLAYERCTL

#
# FILE_END
