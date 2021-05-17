#!/bin/bash
# bash_aliases Config File:
#   location: ~/.bash_aliases
#   author: t3@pfaffe.me  🄯2020-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Bash linter common ignore:
#      - SC1090 = Cant follow source declaration.
#      - SC2015 = Using && || operators for if-else.
#      - SC2034 = Variable appears unused.
#      - SC2059 = Dont use vars in printf format string.
#      - SC2086 = Double qoute str to prevent globbing/splits.
#                 (Probably shouldnt ignore 2086)
#      [src]( https://github.com/koalaman/shellcheck/wiki/Checks )



################################
### INITIALIZE_BASH_ALIASES: ##############################################
################################

## Ignore these error codes globally:
#shellcheck disable=SC2059

## Tag self as linked for dependents:
# shellcheck disable=2034
HAS_BASH_ALIASES=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Script sourcing function:
# shellcheck disable=1090,2086
if ! command -v link_source &>/dev/null ; then link_source() { [[ -f $1 ]] && source $1 || echo "Failed to link ${1}!!"; } ; fi

[ "$HAS_BASH_UTILS" = false ] && ( echo "ERROR! ~/.bash_aliases is not meant to be run without ~/.bashrc !" )


#####################
### CMD Wrappers: ########################################################
#####################

## Define Utilized Files:
SRC_BASH_ALIASES_SCRIPTS=~/.scripts/.bash_aliases_scripts

## Wrapping native POSIX in-terminal cmds:
##########################################
    ## Shortcuts to clear screen:
    # Shortcut to fully clear screen.
    alias clear-full='printf "\033c"'
    # Shortcut clear-full screen
    alias clsfull='clear-full ; motd'
    # Shortcut clear screen
    alias cls='clear'

    ## Wrapping native cmds:
    alias cp="cp -i"            # confirm before overwriting something
    alias df='df -h'            # human-readable sizes
    alias free='free -m'        # show sizes in MB
    alias lsall="pwd ; ls -a"

    ## Return directory sizes:
    function dir_size() {
        local dir_arg=""
        str_empty "$1"  && dir_arg=$(/usr/bin/pwd) || dir_arg=$1 && shift
        local args="$*"
        du -sh --apparent-size "$args" "$dir_arg"  2>/dev/null | cut -d/ -f1
    }
    alias dsize="dir_size"

    ## Visualize directory:
    # shellcheck disable=2086
    show_dir() {
        local dir_arg

        if str_empty "$1" || [[ "$1" == -* ]] ; then dir_arg=$(pwd)
        else dir_arg=$1 && shift ; fi

        local args="-h ${*}"
        local fileCnt=" " ; fileCnt=$( /usr/bin/ls "$dir_arg" $args -1 | /usr/bin/wc -l )
        printf "%s/: %s files, \n" "$dir_arg" "$fileCnt"
        ls "$dir_arg" $args
    }
    alias sd='show_dir'

    ## Directory change but more visual:
    change_dir() {
        str_empty "$1" && return 1
        local dir_arg="$1" ; shift
        local args="$*"

        cd "$dir_arg" || return 1
        show_dir "$dir_arg" "$args" ; return 0
    }
    alias cdir="change_dir"

    ## Shortcut for common directories to cd to:
    alias cdhome='cdir ~'
    alias cddownloads='cdir ~/Downloads'
    alias cdd='cddownloads'
    alias cdprojects='cdir ~/Projects'
    alias cdscripts='cdir ~/Documents/Scripts'
    alias cdconfig='cd ~/.config/'

    # Shortcut to set writable script permissions
    alias mkscript='chmod +x '
##########################################

## Bash operations & shortcuts:
###############################
    ## Shortcuts to reload ~/.bashrc:
    alias reload_bash='clear-full ; reset_debug_logs ; reset_init_msgs ; notify_reload "~/.bashrc" ; source ~/.bashrc'
    # Shortcut reload_bash
    alias rld='reload_bash'

    ## Shortcuts to clear bash_history:
    alias clear_bash_history='rm ~/.bash_history* ; history -c && reload_bash'
    # Shortcut clear_bash_history
    alias clshistory='clear_bash_history'

    ## Shortcuts for editing bash config files:
    alias bashedit="cd ~/ && micro .bashrc .bash_aliases .bash_profile ; show_dir "
###############################

## Native ArchLinux operations/shortcuts:
#########################################
    ## Set default native pkg wrapper:
    alias pacm='/usr/bin/sudo /usr/bin/pacman'
    alias pacmup='pacm --noconfirm -Syu'

    ## Set preferred pkg wrapper:
    if cmd_exists paru  ; then alias pac='/usr/bin/paru'
    elif cmd_exists yay ; then alias pac='/usr/bin/yay'
    else alias pac='pacm' ; fi

    ## Pacman wrapper shortcuts:
    alias pacup='pac --noconfirm -Syu'
    alias pacin='pac --noconfirm -S'
    alias paclist='pac -Qet'
    alias pacclear='pac -Sc'
    alias pacclear-full='pac -Scc'

    ## Displays Reference for various pacman cmds:
    pachelp() {
        local CLR=$COLOR_GRAY
        local TAB="   "

        printf "${COLOR_BLD_WHITE}Pacman Help Quick Reference:${COLOR_NC}\n"

        printf "\nGenerate Lists of Installed Pkgs:\n"
        printf " - List all explicitly installed pkgs\n${TAB}\$ ${CLR}pacman -Qet${COLOR_NC}\n"
        printf " - List all native installed pkgs    \n${TAB}\$ ${CLR}pacman -Qnet${COLOR_NC}\n"
        printf " - List all foreign installed pkgs   \n${TAB}\$ ${CLR}pacman -Qmet${COLOR_NC}\n"

        printf "\nGenerate Lists of Installed Pkgs:\n"
        printf " - Clears tarballs/builds of no longer installed pkgs. \n${TAB}\$ ${CLR}pacman -Sc${COLOR_NC}\n"
        printf " - Clears tarballs/builds of *ALL* installed pkgs.     \n${TAB}\$ ${CLR}pacman -Scc${COLOR_NC}\n"


        #End statement
        printf "\n"
    }

    ## Gets the fastest pacman mirrors:
    # [reference]( https://wiki.archlinux.org/index.php/Mirrors )
    get_fastest_mirrors() {
        printf "Pulling from archlinux.org/mirrorlist and ranking those servers by speed...\n\n"
        curl -s "https://archlinux.org/mirrorlist/?country=US&country=CA&country=CH&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 6 -
        printf "\n done.\n"
    }
#########################################

## Non-native cmd wrappers:
######################

    # Use sudo, but politely
    alias please='sudo'

    # Shortcut for micro text-editor
    alias mi='micro'

    # Shortcut CMDs for Xorg multiseat
    alias enable_multi="export DISPLAY=:0 && /usr/bin/sudo xhost +local: "
    alias disable_multi="/usr/bin/sudo xhost -local: "

    # Shortcut to restore wallpapers with nitrogen
    alias fixwallpaper="nitrogen --restore"

    ## Shortcuts for i3 configurations:
    alias i3edit="cd ~/.config/i3/ ; edit ~/.config/i3/config && ls"
    alias i3statusedit="cd ~/.config/i3status/ ; edit ~/.config/i3status/config && ls"
    alias x-lock='~/.config/i3/scripts/sensible-xlock.sh'
    alias xidle-lock='~/.config/i3/scripts/sensible-xidlelock.sh'

    ## Shortcut to restart i3WM
    alias reload_i3="i3-msg 'restart'"

    ## Shortcut to restart CinnamonDE
    alias reload_cinnamon='cinnamon -replace -d :0.0 > /dev/null 2>&1 &'

    ## Shortcuts for xClip:
    if cmd_exists 'xclip' ; then
        alias setclip="xclip -selection c"
        alias getclip="xclip -selection c -o"
    fi

    ## Shortcuts for Ranger:
    if cmd_exists 'ranger' ; then
        alias ra='ranger'
        #cmd_exists $RANGERCD && unset RANGERCD && ranger_cd
    fi

    ## Shortcut to remap bashtop:
    cmd_exists 'bpytop' && alias bashtop='bpytop'

######################


##################
### SCRIPTING: ############################################################
##################
## Static and dynamically linked functions, scripts, & utilities.

## Pull wallpaper location from nitrogen's config:
####################################
get_nitrogen_wallpaper() {
    local nitrogen_conf=~/.config/nitrogen/bg-saved.cfg
    cmd_exists nitrogen && ( file_exists $nitrogen_conf || return 1 ) || return 1
    local nitrogen_wall=""; nitrogen_wall=$( sed -n 's/^file=//p' $nitrogen_conf | head -n 1 )
    ! str_empty "$nitrogen_wall" && ( echo "$nitrogen_wall" && return 0) ; return 1
}
####################################

## Pull wallpaper location from cinnamon's dconf config:
####################################
get_dconf_wallpaper() {
    cmd_exists gsettings || return 1
    local cinnamon_wall=""; cinnamon_wall=$( gsettings get org.cinnamon.desktop.background picture-uri | sed 's/\x27//g ; s/file\:\/\///g' )
    ! str_empty "$cinnamon_wall" && file_exists "$cinnamon_wall" && echo "$cinnamon_wall" && return 0 ; return 1
}
####################################

## 'macvendor' - Query mac vendor information given address:
## usage: macvendor <address-string>
############################################
macvendor() {
    str_empty "$1" return 1 ; local arg=${1//\:/-}
    local lookup_src='https://api.macvendors.com'
    printf "%s\n" "$(curl $lookup_src'/'"$arg" 2>/dev/null )"
}
############################################

## 'edit' - Preferential tui text-editor:
## usage: edit <file>
#########################################
edit() {
    # Tries i3s preferential edit
	i3-sensible-editor "$1"  && return 0
    # Tries $VISUAL, $EDITOR, and finally xdg-open.
    $VISUAL  "$1" && return 0
    $EDITOR  "$1" && return 0
    xdg-open "$1" 1> /dev/null && return 0
    return 1 # return fail status
} ; alias ed='edit'
#########################################

## 'gui_edit' - Preferential gui text-editor:
## usage: gui_edit <file>
#############################################
gui_edit() {
        xdg-open "$1" 1> /dev/null && return 0
    edit "$1" && return 0
    return 1 # return fail status
} ; alias ged='gui_edit'
#############################################

## 'mandir' - Preferential file-manager selector with fail-over:
## usage: mandir <directory>
########################################
mandir() {
    local args="" ; if str_empty "$1" ; then args=$(pwd) ; else args="$1" ; fi

    # Tries $VISUAL, $EDITOR, and finally xdg-open.
    ranger "$args"  && return 0
    xdg-open "$args" && return 0
    show_dir "$args"  && return 0
    return 1 # return fail status
} ; alias md='mandir'
########################################

## 'extract' - archive extractor:
## usage: extract <file>
#################################
extract() {
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
} ; alias ex='extract'
#################################

## 'pacman_audit' - audit security & pkg health:
## usage: pacman_audit
################################################
pacman_audit() {
    printf "Performing Security Check: "

    printf "\n * Checking for upgradeable packages with known vulnerabilities...."
    local upgradeable_pkgs="" ; upgradeable_pkgs="$(arch-audit -uf '    Package %n has a %s CVE. UPGRADE to version %v!')"
    if [[ -n "${upgradeable_pkgs// }" ]] ; then
        printf "\n"
        echo "$upgradeable_pkgs"
    fi

    printf "\n * Checking for all installed packages with known vulnerabilities... \n"
    arch-audit | grep -i '\(High\|Critical\) risk!' | awk '//{printf "\tPkg %s \t has a vulnerability which is\t %s %s\n", $2, $(NF-1), $NF}'

    printf "\nPerforming PKG Build Check: "
    printf "\n * Checking for PKGs that need to be rebuilt...\n" ;
    checkrebuild | awk '//{printf "\t From [%s]: pkg %s needs to be rebuilt.\n", $1, $2}'

    printf "\n done.\n"
} ; alias pac_audit='pacman_audit'
################################################

## 'show_colors' - display terminal colors:
## usage: 'show_colors'
###########################################
show_colors() {
	local fgc bgc vals seq0

    printf "\e[1mANSI Color Escapes:\e[m\n"
    # shellcheck disable=2016   ## The expression not expanding is intentional.
	printf "  Color escapes are %s\n" '\e[${value} ;... ;${value}m'
	printf "  Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "  Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "  Value  1 gives a  \e[1mbold-faced look\e[m\n"
    printf "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n\n"

    # shellcheck disable=2059
	for fgc in {30..37}; do     ## Iterate foreground colors:
        printf " "
		for bgc in {40..47}; do     ## Iterate background colors:
			fgc=${fgc#37}               # White code
			bgc=${bgc#40}               # Black code
			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}
            seq0="${vals:+\e[${vals}m}"

			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done ; echo; echo
	done
}
###########################################

## Get & Set wallpaper ENV Var:
##############################
define_wallpaper() {
    # Set Wallpaper location ENV Var
    local cmd_output=""
    cmd_output=$(get_dconf_wallpaper) || cmd_output=$(get_nitrogen_wallpaper) || return 1
    export WALLPAPER=${cmd_output} && return 0 || return 1
} ; alias define_wallpaper_var='define_wallpaper'
##############################

## Link to user scripts bash_aliases_scripts file:
# shellcheck source=src/Documents/Scripts/.bash_aliases_scripts
link_source $SRC_BASH_ALIASES_SCRIPTS


#
## END_FILE
