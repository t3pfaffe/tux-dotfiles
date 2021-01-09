#!/bin/bash
# bash_aliases Config File:
#   location: ~/.bash_aliases
#   author: t3@pfaffe.me  🄯2020-01/05/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


SRC_BASH_ALIASES_SCRIPTS=~/Documents/Scripts/.bash_aliases_scripts

#####################
### CMD Wrappers: ########################################################
#####################

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
alias reload_bash="clear_full; notify_reload '~/.bashrc'; source ~/.bashrc"
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
alias more=less

## Shortcut for common directories to cd to:
alias cdhome='cd ~'
alias cd~='cd ~'
alias cddownloads='cd ~/Downloads'
alias cdprojects='cd ~/Projects'
alias cdscripts='cd ~/Documents/Scripts'
alias cdconfig='cd ~/.config/'

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

# Shortcut for micro text-editor
alias mi='micro'

# Shortcuts for Ranger
alias ra='ranger'
#cmd_exists $RANGERCD && unset RANGERCD && ranger_cd


# Shortcut to restore wallpapers with nitrogen
alias fixwallpaper="nitrogen --restore"
## Pull wallpaper location from nitrogen's' config:
get_wallpaper () {
    command -v nitrogen >/dev/null || return 1
    nitrogen_conf=~/.config/nitrogen/bg-saved.cfg
    [ -f $nitrogen_conf ] && echo "$( sed -n 's/^file=//p' $nitrogen_conf | head -n 1 )" || return 1
}

## Shortcuts for i3 configuration
alias i3edit="cd ~/.config/i3/ ; edit ~/.config/i3/config && ls"
alias i3statusedit="cd ~/.config/i3status/ ; edit ~/.config/i3status/config && ls"
alias lock_screen='~/.config/i3/lock-screen.sh'

## Shortcut to restart CinnamonDE
alias reload_cinnamon='cinnamon -replace -d :0.0 > /dev/null 2>&1 &'

## Shortcuts for xClip
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
######################


##################
### SCRIPTING: ############################################################
##################
## Static and dynamically linked scripts / utilities.

## 'edit' - Preferential text-editor selector with fail-over:
## usage: edit <file>
########################################
edit () {
	# Tries i3's preferential edit
	i3-sensible-editor $1 && return 0
    # Tries $VISUAL, $EDITOR, and finally xdg-open.
    $VISUAL $1  && return 0
    printf '$VISUAL editor failed. Trying $EDITOR... \n'
    $EDITOR $1  && return 0
    printf '$VISUAL & $EDITOR editor both failed. Trying xdg-open... \n'
    xdg-open $1 && return 0 || return 1
}

# Shortcut to edit script
alias ed='edit'
########################################

## 'showdir' - Preferential file-manager selector with fail-over:
## usage: showdir <directory>
########################################
showdir () {
    # Tries $VISUAL, $EDITOR, and finally xdg-open.
    local args=""; if str_empty "$1"; then args=$(pwd); else args="$1" ; fi

    ranger $args  && return 0
    xdg-open $args && return 0 && return 0
    pwd $args; ls $args && return 0 || return 1
}

# Shortcut to edit script
alias sd='showdir'

########################################

## 'extract' - archive extractor:
## usage: extract <file>
#################################
extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
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
        echo $upgradeable_pkgs
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

##Show terminal colors:
#######################
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
#######################

## Get & Set wallpaper ENV Var:
##############################
set_wallpaper_var () {
    # Set Wallpaper location ENV Var
    local cmd_output="";cmd_output=$(get_wallpaper) || return 1
    export WALLPAPER=${cmd_output} && return 0 || return 1
}
##############################

## Link to user scripts bash_aliases_scripts file:
# shellcheck source=src/Documents/Scripts/.bash_aliases_scripts
if file_exists $SRC_BASH_ALIASES_SCRIPTS; then  source $SRC_BASH_ALIASES_SCRIPTS || notify_link_err $SRC_BASH_ALIASES_SCRIPTS; fi



#
## END_FILE
