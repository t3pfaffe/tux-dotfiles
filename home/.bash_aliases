#!/bin/bash
# bash_aliases Config File:
#   location: ~/.bash_aliases
#   author: t3@pfaffe.me  🄯2020-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



################################
### INITIALIZE_BASH_ALIASES: ##############################################
################################

# Tag self for dependents
HAS_BASH_ALIASES=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#
if ! $HAS_BASHRC ; then "ERROR! ~/.bash_aliases is not meant to be run without ~/.bashrc !" ; return ; fi

#####################
### CMD Wrappers: ########################################################
#####################

## Define Utilized Files:
SRC_BASH_ALIASES_SCRIPTS=~/.scripts/.bash_aliases_scripts

## Native bash/unix cmds:
#########################

## Shortcuts to clear screen:
# Shortcut to fully clear screen.
alias clear_full='printf "\033c"'
# Shortcut clear_full screen
alias clsfull='clear_full; motd'
# Shortcut clear screen
alias cls='clear'

## Shortcuts to reload ~/.bashrc:
alias reload_bash='clear_full; reset_debug_logs ; reset_init_msgs ; notify_reload "~/.bashrc" ; source ~/.bashrc'
# Shortcut reload_bash
alias rld='reload_bash'

## Shortcuts to clear bash_history:
alias clear_bash_history='rm ~/.bash_history*; history -c && reload_bash'
# Shortcut clear_bash_history
alias clshistory='clear_bash_history'

## Wrapping native cmds:
alias cp="cp -i"            # confirm before overwriting something
alias df='df -h'            # human-readable sizes
alias free='free -m'        # show sizes in MB
alias lsall="pwd; ls -a"

## Return directory sizes:
function dir_size() {
    local dir_arg=""
    str_empty "$1"  && dir_arg=$(pwd) || dir_arg=$1 && shift
    local args="$*"
    echo "$( du -sh --apparent-size "$args" "$dir_arg"  2>/dev/null | cut -d/ -f1 )"
}
alias dsize="dir_size"

## Visualize directory:
show_dir () {
    local dir_arg="" ; if str_empty "$1" ; then dir_arg=$(pwd) ; else dir_arg=$1 && shift; fi
    local args="$*"
    local fileCnt="" ; fileCnt=$( /usr/bin/ls  "$args" "$dir_arg" -1 | /usr/bin/wc -l ) || local fileCnt="null"


    printf "%s/: %s files, \n" "$dir_arg"  "$fileCnt"
    ls "$args" "$dir_arg"
}

## More visual directory change::
change_dir () {
    str_empty "$1"  && return 1
    local dir_arg="$1"; shift
    local args="$*"

    cd "$dir_arg" || return 1; show_dir "$args" ; return 0
}
alias cdir="change_dir"

## Shortcut for common directories to cd to:
alias cdhome='cd ~'
alias cddownloads='cd ~/Downloads'
alias cdconfig='cd ~/.config/'
alias cdprojects='cdir ~/Projects'
alias cdscripts='cdir ~/Documents/Scripts'

# Shortcut to set writable script permissions
alias mkscript='chmod +x '
#########################

## Native Arch cmds:
#####################
## Wrapping Arch cmds:
alias pac='sudo pacman'

## Gets the fastest pacman mirrors:
# [reference]( https://wiki.archlinux.org/index.php/Mirrors )
get_fastest_mirrors () {
    printf "Pulling from archlinux.org/mirrorlist and ranking those servers by speed...\n\n"
    curl -s "https://archlinux.org/mirrorlist/?country=US&country=CA&country=CH&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 6 -
    printf "\n done.\n"
}
#####################

##USER Installed cmds:
######################

# Use sudo politely
alias please='sudo'

# Use paru instead of yay
alias yay='paru'

# Shortcut to package manager
alias up='paru'

# Shortcut for micro text-editor
alias mi='micro'

# Shortcuts for Ranger
alias ra='ranger'
#cmd_exists $RANGERCD && unset RANGERCD && ranger_cd


# Shortcut to restore wallpapers with nitrogen
alias fixwallpaper="nitrogen --restore"
## Pull wallpaper location from nitrogen's' config:
get_nitrogen_wallpaper () {
    command -v nitrogen >/dev/null || return 1
    nitrogen_conf=~/.config/nitrogen/bg-saved.cfg
    [ -f $nitrogen_conf ] && echo "$( sed -n 's/^file=//p' $nitrogen_conf | head -n 1 )" || return 1
}

## Shortcuts for i3 configuration
alias i3edit="cd ~/.config/i3/ ; edit ~/.config/i3/config && ls"
alias i3statusedit="cd ~/.config/i3status/ ; edit ~/.config/i3status/config && ls"
alias x-lock='~/.config/i3/scripts/sensible-xlock.sh'
alias xidle-lock='~/.config/i3/scripts/sensible-xidlelock.sh'

## Shortcut to restart i3WM
alias reload_i3="i3-msg 'restart'"

## Shortcut to restart CinnamonDE
alias reload_cinnamon='cinnamon -replace -d :0.0 > /dev/null 2>&1 &'

## Shortcuts for xClip
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
######################


##################
### SCRIPTING: ############################################################
##################
## Static and dynamically linked functions, scripts, & utilities.

## 'edit' - Preferential text-editor:
## usage: edit <file>
####################################
edit () {

	# Tries i3s preferential edit
	i3-sensible-editor "$1"  && return 0
    # Tries $VISUAL, $EDITOR, and finally xdg-open.
    $VISUAL  "$1" && return 0
    $EDITOR  "$1" && return 0
    xdg-open "$1" && return 0
    return 1 # return fail status
}
# Shortcut to edit function
alias ed='edit'
#####################################

## 'mandir' - Preferential file-manager selector with fail-over:
## usage: mandir <directory>
########################################
mandir () {
    local args=""; if str_empty "$1"; then args=$(pwd); else args="$1" ; fi

    # Tries $VISUAL, $EDITOR, and finally xdg-open.
    ranger "$args"  && return 0
    xdg-open "$args" && return 0
    show_dir "$args"  && return 0
    return 1 # return fail status
}
# Shortcut to mandir function
alias md='mandir'

########################################

## 'extract' - archive extractor:
## usage: extract <file>
#################################
extract () {
  if [ -f "$1"  ] ; then
    case "$1"  in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "File '$1' cannot be extracted via extract()." ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

alias ex='extract'
#################################

## 'pacman_audit' - audit security & pkg health:
## usage: pacman_audit
################################################
pacman_audit () {
    printf "Performing Security Check: "

    printf "\n * Checking for upgradeable packages with known vulnerabilities...."
    local upgradeable_pkgs=""; upgradeable_pkgs="$(arch-audit -uf '    Package %n has a %s CVE. UPGRADE to version %v!')"
    if [[ ! -z "${upgradeable_pkgs// }" ]]; then
        printf "\n"
        echo "$upgradeable_pkgs"
    fi

    printf "\n * Checking for all installed packages with known vulnerabilities... \n"
    arch-audit | grep -i '\(High\|Critical\) risk!' | awk '//{printf "\tPkg %s \t has a vulnerability which is\t %s %s\n", $2, $(NF-1), $NF}'

    printf "\nPerforming PKG Build Check: "
    printf "\n * Checking for PKGs that need to be rebuilt...\n";
    checkrebuild | awk '//{printf "\t From [%s]: pkg %s needs to be rebuilt.\n", $1, $2}'

    printf "\n done.\n"
}

alias pac_audit='pacman_audit'
################################################

## 'show_colors' - display terminal colors:
## usage: 'show_colors'
###########################################
show_colors () {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}
###########################################

## Get & Set wallpaper ENV Var:
##############################
define_wallpaper_var () {
    # Set Wallpaper location ENV Var
    local cmd_output="";cmd_output=$(get_nitrogen_wallpaper) || return 1
    export WALLPAPER=${cmd_output} && return 0 || return 1
}
##############################

## Link to user scripts bash_aliases_scripts file:
# shellcheck source=src/Documents/Scripts/.bash_aliases_scripts
if file_exists $SRC_BASH_ALIASES_SCRIPTS; then  source $SRC_BASH_ALIASES_SCRIPTS || debug_notify_link_warn $SRC_BASH_ALIASES_SCRIPTS; fi


#
## END_FILE
