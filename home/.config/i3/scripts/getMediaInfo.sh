#!/bin/bash
# shell script to prepend i3Status with mediaInfo

MEDIA_NOTE="♪♪"
MEDIA_PLAY="▶"
MEDIA_PAUSE="⏸"

MEDIA_INFO=""
MEDIA_INFO_LONG=""

xml_escape() {
    if
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

updateMediaInfo() {

	#Pull Media Info
	local STATUS="$(playerctl --player=spotify,%any status || echo "noPlayers")"
	if [ $STATUS = "noPlayers" ]; then
		MEDIA_INFO=""; MEDIA_INFO_LONG=""; return 0; fi

	local MEDIA_TITLE="$(playerctl --player=spotify,%any metadata title)"
        local MEDIA_ARTIST="$(playerctl --player=spotify,%any metadata artist)"
        local MEDIA_STATE=""
	##


	if [ "$STATUS" = "Playing" ]; then
                MEDIA_STATE="$MEDIA_PLAY"
        elif [ "$STATUS" = "Paused" ]; then
                MEDIA_STATE="$MEDIA_PAUSE"
	else
		MEDIA_STATE="⏹"
	fi

	local MEDIA_TITLE=$(xml_escape "$MEDIA_TITLE")
	local MEDIA_ARTIST=$(xml_escape "$MEDIA_ARTIST")

	local MEDIA_PREPEND="$MEDIA_NOTE($MEDIA_STATE)"
	MEDIA_INFO="$MEDIA_PREPEND - $MEDIA_TITLE "
	MEDIA_INFO_LONG="$MEDIA_PREPEND $MEDIA_TITLE - $MEDIA_ARTIST "
}

i3status | (read line && echo "$line" && read line && echo "$line" && read line && echo "$line" && updateMediaInfo && while :
do
	read line && updateMediaInfo

	#Format MEDIA_INFO for i3Status XML
	MEDIA_LINE="{\"name\":\"media_info\",\"markup\":\"pango\",\"border_bottom\":3,\"separator_block_width\":3,\"align\":\"right\",\"short_text\":\"${MEDIA_INFO}\",\"full_text\":\"${MEDIA_INFO_LONG}\"}"

	echo ",[${MEDIA_LINE},${line#,\[}" || echo "$line" || exit 1

done)
