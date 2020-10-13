#!/bin/bash
# shell script to prepend i3Status with mediaInfo

MEDIA_INFO=""
MEDIA_INFO_LONG=""

updateMediaInfo() {
	local STATUS="$(playerctl --player=spotify,%any status || echo "noPlayers")"
	if [ $STATUS = "noPlayers" ]; then 
		MEDIA_INFO=""; MEDIA_INFO_LONG=""; return 0; fi	

	local MEDIA_TITLE="$(playerctl --player=spotify,%any metadata title)"
        local MEDIA_ARTIST="$(playerctl --player=spotify,%any metadata artist)"
        local MEDIA_STATE=""
	local MEDIA_NOTE="♪♪"	

	if [ "$STATUS" = "Playing" ]; then
                MEDIA_STATE="▶"
        elif [ "$STATUS" = "Paused" ]; then
                MEDIA_STATE="⏸"
	else 
		MEDIA_STATE="⏹"
        fi
	
	local JSON_TOPIC_RAW=${MEDIA_TITLE} 
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\\/\\\\} # \ 
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\//\\\/} # / 
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\"/\\\"} # " 
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//   /\\t} # \t  (tab)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW///\\\n}   # \n  (newline)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^M/\\\r} # \r  (carriage return)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^L/\\\f} # \f  (form feed)
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^H/\\\b} # \b  (backspace)	
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//&/\and}  # and (ampersand)
	local MEDIA_TITLE=${JSON_TOPIC_RAW}

	local JSON_TOPIC_RAW=${MEDIA_ARTIST}
	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\\/\\\\} # \
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\//\\\/} # /
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//\"/\\\"} # "
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//   /\\t} # \t  (tab)
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW///\\\n}   # \n  (newline)
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^M/\\\r} # \r  (carriage return)
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^L/\\\f} # \f  (form feed)
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//^H/\\\b} # \b  (backspace)
    	local JSON_TOPIC_RAW=${JSON_TOPIC_RAW//&/\and}  # and (ampersand)
    	local MEDIA_ARTIST=${JSON_TOPIC_RAW}


	local MEDIA_PREPEND="$MEDIA_NOTE($MEDIA_STATE)"
	MEDIA_INFO="$MEDIA_PREPEND - $MEDIA_TITLE "
	MEDIA_INFO_LONG="$MEDIA_PREPEND $MEDIA_TITLE - $MEDIA_ARTIST "
}

i3status | (read line && echo "$line" && read line && echo "$line" && read line && echo "$line" && updateMediaInfo && while :
do
        read line && updateMediaInfo

	MEDIA_LINE="{\"name\":\"media_info\",\"markup\":\"pango\",\"border_bottom\":3,\"separator_block_width\":3,\"align\":\"right\",\"short_text\":\"${MEDIA_INFO}\",\"full_text\":\"${MEDIA_INFO_LONG}\"}"
	echo ",[${MEDIA_LINE},${line#,\[}" || echo "$line" || exit 1
done)
