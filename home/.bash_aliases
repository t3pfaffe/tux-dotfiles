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
# shellcheck disable=SC2015,SC2059

## Tag self as linked for dependents:
# shellcheck disable=2034
declare HAS_BASH_ALIASES=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Script sourcing function:
# shellcheck disable=1090,2086
if ! command -v link_source &>/dev/null; then link_source() { [[ -f $1 ]] && source $1 || echo "Failed to link ${1}!!"; }; fi

"$HAS_BASH_UTILS" || ( echo "ERROR! ~/.bash_aliases is not meant to be run without ~/.bashrc !" )


#####################
### CMD Wrappers: ########################################################
#####################

## Define Utilized Files:
SRC_BASH_ALIASES_SCRIPTS=~/.scripts/.bash_aliases_scripts

## Wrapping native POSIX in-terminal cmds:
#########################################
    ## Shortcuts to clear screen:
    # Shortcut to fully clear screen.
    alias clear-full='printf "\033c"'
    # Shortcut clear-full screen
    alias clsf='clear-full; motd'
    # Shortcut clear screen
    alias cls='clear'

    ## Wrapping native cmds:
    alias cp="cp -i"            # confirm before overwriting something
    alias df='df -h'            # human-readable sizes
    alias free='free -m'        # show sizes in MB
    alias lsa="pwd; ls -a"

    ## Return directory sizes:
    function dir_size() {
        local dir_arg=""
        str_empty "$1"  && dir_arg=$(/usr/bin/pwd) || dir_arg=$1 && shift
        local args="$*"
        du -sh --apparent-size "$args" "$dir_arg"  2>/dev/null | cut -d/ -f1
    }
    alias dsize="dir_size"

    ## Visualize a given directory:
    # shellcheck disable=2086  ## Not double-qouting is intentional here.
    show_dir() {
        local dir_arg args fileCnt

        ## Defaults target dir to current if no other is specified in $1:
        if str_empty "$1" || [[ "$1" == -* ]]; then dir_arg=$(pwd)
        else dir_arg=$1 && shift; fi

        args="-h ${*}";
        fileCnt=$( /usr/bin/ls "$dir_arg" $args -1 | /usr/bin/wc -l || printf " " )
        printf "%s/: %s files, \n" "$dir_arg" "$fileCnt"
        /usr/bin/exa "$dir_arg" --icons --header --git --long $args
    }
    alias sd='show_dir'

    ## Directory change but more visual:
    change_dir() {
        str_empty "$1" && return 1
        local dir_arg="$1"; shift
        local args="$*"

        cd "$dir_arg" || return 1
        show_dir "$dir_arg" "$args"; return 0
    }
    alias cdir="change_dir"

    ## Shortcut for common directories to cd to:
    alias cdlast='cd -'
    alias cdhome='cdir ~'; alias cdh='cdhome'
    alias cddownloads='cdir ~/Downloads'; alias cdd='cddownloads'
    alias cdprojects='cdir ~/Projects';
    alias cdscripts='cdir ~/Documents/Scripts'
    alias cdconfig='cd ~/.config/'

    # Shortcut to set writable script permissions
    alias mkscript='chmod +x '
#########################################

## Bash operations & shortcuts:
##############################

    ## Shortcuts to reload ~/.bashrc:
    reload_bash() {
        local do_notif=true; local do_clr=true; local do_logreset=false; local do_quiet=false; local prev_do_motd=$BASH_DO_SHOW_MOTD

        if [ $# -ge 1 ]; then for i in "$@"; do case $i in
            -h|--help) printf "Reload current bash session with latest config:\n\t-h|--help \n\t-n|--no-notice \n\t-c|--no-clear \n\t-l|--log-reset \n\t-q|--quiet \n"; return 0;;
            -n|--no-notice)    do_notif=false; shift;;
            -c|--no-clear)     do_clr=false;   shift;;
            -l|--log-reset)  do_logreset=true; shift;;
            -q|--quiet) do_quiet=true; do_notif=false; shift;;
            *-[!\ ]*) printf "Error: '%s' is not a valid parameter!\n" "${1}"; return 1;;
        esac; done; fi

        ## Follow argument toggles provided:
        $do_clr      && clear-full
        $do_quiet    && BASH_DO_SHOW_MOTD=false;
        $do_logreset && reset_debug_logs; reset_init_msgs
        $do_notif    && notify_info_reload "$HOME/.bashrc"

        ## Reloading of latest bash conf:
        # shellcheck disable=1091
        source "$HOME"/.bashrc;

        ## Set state's back to previous on return:
        $do_quiet && BASH_DO_SHOW_MOTD=$prev_do_motd
    }; alias rld='reload_bash'

    ## Shorthand for common reload_bash params:
    alias rldn='reload_bash -n'
    alias rldq='reload_bash -q'

    ## Shortcuts to clear bash_history:
    clear_bash_history() {
        local do_notif=true; local do_clr=true; local do_quiet=false;
        local dlt_session=true; local dlt_files=true; local do_rld=true; local do_dryrun=false;

        if [ $# -ge 1 ]; then for i in "$@"; do case $i in
            -h|--help) printf "Clear the current bash session's history/persistant(files) bash history:\n\t-h|--help \n\t-f|--no-files-clr \n\t-s|--no-session-clr \n\t-q|--quiet \n\t-r|--no-rld \n\t-n|--no-notice \n\t-c|--no-clear \n\t-d|--dry-run \n"; return 0;;
            -f|--no-files-clr)      dlt_files=false;   shift;;
            -s|--no-session-clr)    dlt_session=false; shift;;
            -q|--quiet) do_quiet=true; do_notif=false; shift;;
            -r|--no-rld)            do_rld=false;   shift;;
            -n|--no-notice)         do_notif=false; shift;;
            -c|--no-clear)          do_clr=false;   shift;;
            -d|--dry-run) do_dryrun=true; dlt_session=false; dlt_files=false; shift;;
            --[!\ ]*) printf "Error: '%s' is not a valid parameter!\n" "${1}"; return 1;;
        esac; done; fi

        if ( ! $do_dryrun ) && ( ! $dlt_session && ! $dlt_files ); then rld_params=false; fi

        ## Perform history clear operations:
        "$dlt_session" && history -c; "$do_notif" && debug_notify_info "Cleared bash session's history.";
        "$dlt_files" && /usr/bin/rm ~/.bash_history* 2>/dev/null; "$do_notif" && debug_notify_info "Removed persistent bash_history files in user directory.";

        ## Bash reload params:
        if $rld_params; then
            local rld_params=''
            "$do_quiet" && rld_params="${rld_params} "--quiet
            "$do_clr"   || rld_params="${rld_params} "--no-clear
            reload_bash --no-clear
        fi
    }
    # alias cls_history='clear_bash_history'

    ## Shortcuts for editing bash config files:
    alias bashedit='cd ~/ && ${VISUAL} $HOME/.bashrc $HOME/.bash_aliases $HOME/.bash_profile; show_dir $HOME/.bash*'
##############################

## Wrapping Arch Linux pkg management cmds:
##########################################
    ## Default native pacman shortcuts:
    alias pacn='/usr/bin/sudo /usr/bin/pacman'
    alias pacnup='pacman_update --no-aur --no-flat'

    ## Detect installed pacman wrappers/pkg managers:
    cmd_exists /usr/bin/paru && declare -g -r PKG_HAS_paru=true &> /dev/null
    cmd_exists /usr/bin/yay  && declare -g -r PKG_HAS_yay=true  &> /dev/null
    cmd_exists /usr/bin/tldr && declare -g -r PKG_HAS_tldr=true &> /dev/null
    cmd_exists /usr/bin/flatpak && declare -g -r PKG_HAS_flatpak=true &> /dev/null

    ## Set preferred pkg wrapper:
    if $PKG_HAS_paru; then
        alias pac='/usr/bin/paru'
        alias pacinre='/usr/bin/paru --noconfirm -S --redownload --rebuild'
    elif $PKG_HAS_yay; then alias pac='/usr/bin/yay'
    else alias pac='pacn'; fi

    ## Pacman shortcuts:
    alias pacin='pac --noconfirm -S'
    alias pacrm='pac -Rcns'
    alias paclist='pac -Qet'
    alias pacclear='pac -Sc'
    alias pacclear-full='pac -Scc'

	if $PKG_HAS_flatpak; then
        alias flat='/usr/bin/flatpak'
	    alias flatup='/usr/bin/flatpak update --noninteractive '
    fi

    ## Comprehensive non-interactive system update shortcut:
    #######################################################
    pacman_update() {
        local pacup_cmd pac_cmd; local do_noint=true; local do_quiet=false; local do_noaur=false; local do_noflat=false; local do_notldr=false

        if [ $# -ge 1 ]; then for i in "$@"; do case $i in
        	-h|--help) printf "Comprehensive Arch pkg update wrapper:\n\t-h|--help \n\t-i|--interactive \n\t-q|--quiet \n\t<>|--no-<aur,flat,tldr> \n"; return 0;;
            -i|--interactive) do_noint=false; do_quiet=false; shift;;
            -q|--quiet) do_quiet=true; do_noint=true; shift;;
            --no-aur)  do_noaur=true;  shift;;
            --no-flat) do_noflat=true; shift;;
            --no-tldr) do_notldr=true; shift;;
            *-[!\ ]*|*--[!\ ]*) printf "Error: '%s' is not a valid parameter!\n" "${1}"; return 1;;
        esac; done; fi

        pac_cmd='sudo /usr/bin/pacman -Syu '
        $do_noaur || pac_cmd='pac -Syu --sudoloop --cleanafter --skipreview '
        $do_noint && pac_cmd+=' --noconfirm '
        $do_quiet && pac_cmd+=' 1>/dev/null '
        pacup_cmd="${pac_cmd}; "

        ## Add cmd hooks to update non-pacman packages as well:
        $PKG_HAS_flatpak && $do_noflat || pacup_cmd+='flatup; '
        $PKG_HAS_tldr    && $do_notldr || pacup_cmd+='tldr -u -q; '

        ## Run the update:
        if $do_quiet; then eval "$pacup_cmd" 1>/dev/null && return 0
        else eval "$pacup_cmd" && return 0; fi

        return 1 # Return fail condiiton
    }; alias pacup='pacman_update'
    #######################################################

    pacman_update_reboot() {
        local do_forceboot=false; local args

        if [ $# -ge 1 ] && [[ "$1" == -* ]]; then
            case "$1" in
            -F|--force-reboot) shift;;
            -h|--help) pacman_update --help; printf "\t-F|--force\n\t-i"; return 0;;
            *);;
        esac; fi

        args="${*}"

        # shellcheck disable=2086  ## Not double-qouting is intentional here.
        pacman_update $args && { shutdown --reboot now || { $do_forceboot && sudo systemctl reboot --check-inhibitors=no --force; }; }
        #true && { echo "norm reboot fail"; { $do_forceboot && echo "hard reboot try"; }; }
    }; alias pacup_reboot='pacman_update_reboot'


    ## Displays Reference for various pacman cmds:
    pachelp() {
        local CLR='\e[48;5;8m'
        local TAB="    "

        printf "${COLOR_BLD_WHITE}Pacman Help Quick Reference:${COLOR_NC}\n"

		printf "\nRequest information on specific Pkgs:\n"
        printf " - List files owned by a pkg   \n${TAB}${CLR}\$ pacman -Qlq <\$pkg>${COLOR_NC}\n"

        printf "\nGenerate Lists of Installed Pkgs:\n"
        printf " - List all explicitly installed pkgs\n${TAB}${CLR}\$ pacman -Qet  ${COLOR_NC}\n"
        printf " - List all native installed pkgs    \n${TAB}${CLR}\$ pacman -Qnet ${COLOR_NC}\n"
        printf " - List all foreign installed pkgs   \n${TAB}${CLR}\$ pacman -Qmet ${COLOR_NC}\n"
        printf " - Interactively list all installed pkgs   \n${TAB}${CLR}\$ pacman -Qq | fzf --preview 'pacman -Si {}' --layout=reverse ${COLOR_NC}\n"

        printf "\nClear excess files from pkg cache's:\n"
        printf " - Clears tarballs/builds of no longer installed pkgs. \n${TAB}${CLR}\$ pacman -Sc${COLOR_NC}\n"
        printf " - Clears tarballs/builds of *ALL* installed pkgs.     \n${TAB}${CLR}\$ pacman -Scc${COLOR_NC}\n"

        #End statement
        printf "\n"
    }

    ## Gets the fastest pacman mirrors:
    # [reference]( https://wiki.archlinux.org/index.php/Mirrors )
    get_fastest_mirrors() {
        printf "Pulling from archlinux.org/mirrorlist and ranking those servers by speed...\n\n"
        curl -s "https://archlinux.org/mirrorlist/?country=US&country=CA&country=CH&protocol=https&use_mirror_status=on" \
        | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 6 -
        printf "\n done.\n"
    }
##########################################

## Non-native cmd wrappers:
##########################

    # Use sudo, but politely
    alias please='sudo'

    # Shortcut for micro text-editor
    cmd_exists 'micro' && alias mi='/usr/bin/micro'

    # Shortcuts to remap ls to exa
	cmd_exists 'exa' && alias ls='/usr/bin/exa'

    # Shortcut CMDs for Xorg multiseat
    alias enable_multi="export DISPLAY=:0 && /usr/bin/sudo xhost +local: "
    alias disable_multi="/usr/bin/sudo xhost -local: "

    # Shortcut to restore wallpapers with nitrogen
    alias fixwallpaper="nitrogen --restore"

    ## Shortcuts for i3 configurations:
    alias i3edit="cd ~/.config/i3/; edit ~/.config/i3/config && ls"
    alias i3statusedit="cd ~/.config/i3status/; edit ~/.config/i3status/config && ls"
    alias x-lock='~/.config/i3/scripts/sensible-xlock.sh'
    alias xidle-lock='~/.config/i3/scripts/sensible-xidlelock.sh'

    ## Shortcut to logout & kill the current session
    alias end_session='/usr/bin/loginctl terminate-session ${XDG_SESSION_ID}'

    ## Shortcut to logout & kill the current Cinnamon Session
    alias end_cinnamon='/usr/bin/cinnamon-session-quit || end_session '

    ## Shortcut to restart i3WM
    alias reload_i3="/usr/bin/i3-msg 'restart'"

    ## Shortcut to restart CinnamonDE
    alias reload_cinnamon='/usr/bin/cinnamon --replace -d :0.0 > /dev/null 2>&1 &'

    ## Shortcuts for xClip:
    if cmd_exists 'xclip'; then
        alias setclip="xclip -selection c"
        alias getclip="xclip -selection c -o"
    fi

    ## Shortcuts for Ranger:
    if cmd_exists 'ranger'; then
        alias ra='ranger'
        #cmd_exists $RANGERCD && unset RANGERCD && ranger_cd
    fi

##########################


##################
### SCRIPTING: ############################################################
##################
## Static and dynamically linked functions, scripts, & utilities.

## 'check_git_updates' - Query remote repository to check if local is up to date.
## usage: check_git_updates
check_git_updates() {
    git status &>/dev/null || { printf "Error: Current directory is not a git repository!\n"; return 1; }

    [ "$(git log --pretty=%H ...refs/heads/master^ | head -n 1)" = "$(git ls-remote origin -h refs/heads/master |cut -f1)" ]\
      && { printf "No pending changes on remote, repository is up to date.\n"; return 0; } || { printf "Notice: Repository is NOT up to date!\n"; return 1; }

}; alias check_git='check_git_updates'

## 'get_pub_ip' - Query for this device's public ip:
## usage: get_pub_ip
###################################################
get_public_ip() {
    local request_uri='https://wtfismyip.com/text'
    local err_msg="Error: Failed to pull IP info from API web service."
    local cmd_output

    if ( cmd_exists /usr/bin/curl ); then
        cmd_output=$( /usr/bin/curl $request_uri 2>/dev/null ) || { printf "%s\n" "$err_msg"; return 1; }
    elif ( cmd_exists /usr/bin/wget ); then
        cmd_output=$( /usr/bin/wget -qO - $request_uri 2>/dev/null ) || { printf "%s\n" "$err_msg"; return 1; }
    else { printf "%s\n" "${err_msg} (No valid cmd methods!)"; return 1; }
    fi

    ! str_empty "$cmd_output" && { echo "$cmd_output"; return 0; } ## return succesful cmd output
    return 1 ## return fail status
}; alias get_ip='get_public_ip'
###################################################

## 'find_mac_vendor' - Query mac vendor information given address:
## usage: find_mac_vendor <address-string>
#################################################################
find_mac_vendor() {
    str_empty "$1" && return 1; local arg=${1//\:/-}
    local service_uri='https://api.macvendors.com'
    local request_uri=$service_uri'/'"$arg"
    local err_msg="Error: Failed to pull mac vendor info from API web service."
    local cmd_output

    if ( ! cmd_exists /usr/bin/curl ); then
        cmd_output=$( /usr/bin/curl "$request_uri" 2>/dev/null ) || { printf "%s\n" "$err_msg"; return 1; }
    elif ( cmd_exists /usr/bin/wget ); then
        cmd_output=$( /usr/bin/wget -qO - "$request_uri" 2>/dev/null ) || { printf "%s\n" "$err_msg"; return 1; }
    else { printf "%s\n" "${err_msg} (No valid cmd methods to pull vendor!)"; return 1; }
    fi

    ! str_empty "$cmd_output" && { echo "$cmd_output"; return 0; } ## return succesful cmd output
    return 1 ## return fail status
}; alias find_vendor='find_mac_vendor'
#################################################################

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
}; alias ed='edit'
#########################################

## 'gui_edit' - Preferential gui text-editor:
## usage: gui_edit <file>
#############################################
gui_edit() {
    xdg-open "$1" 2> /dev/null && return 0

    edit "$1" && return 0
    return 1 # return fail status
}; alias ged='gui_edit'
#############################################

## 'mandir' - Preferential file-manager selector with fail-over:
## usage: mandir <directory>
########################################
mandir() {
    local args=""; if str_empty "$1"; then args=$(pwd); else args="$1"; fi

    # Tries $VISUAL, $EDITOR, and finally xdg-open.
    ranger "$args"  && return 0
    xdg-open "$args" && return 0
    show_dir "$args"  && return 0
    return 1 # return fail status
}; alias md='mandir'
########################################

## 'extract' - archive extractor:
## usage: extract <file>
#################################
extract() {
  if [ -f "$1"  ]; then
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
}; alias ex='extract'
#################################

## 'pacman_audit' - audit security & pkg health:
## usage: pacman_audit
################################################
pacman_audit() {
    printf "Performing Security Check: "

    printf "\n * Checking for upgradeable packages with known vulnerabilities...."
    local upgradeable_pkgs=""; upgradeable_pkgs="$(arch-audit -uf '    Package %n has a %s CVE. UPGRADE to version %v!')"
    if [[ -n "${upgradeable_pkgs// }" ]]; then
        printf "\n"
        echo "$upgradeable_pkgs"
    fi

    printf "\n * Checking for all installed packages with known vulnerabilities... \n"
    arch-audit | grep -i '\(High\|Critical\) risk!' | awk '//{printf "\tPkg %s \t has a vulnerability which is\t %s %s\n", $1, $(NF-1), $NF}'

    printf "\nPerforming PKG Build Check: "
    printf "\n * Checking for PKGs that need to be rebuilt...\n" ;
    checkrebuild | awk '//{printf "\t From [%s]: pkg %s needs to be rebuilt.\n", $1, $2}'

    printf "\n done.\n"
}; alias pac_audit='pacman_audit'
################################################

## 'show_colors' - display terminal colors:
## usage: 'show_colors'
###########################################
show_colors() {
	local fgc bgc vals seq0


    printf "\e[1mANSI Color Escapes:\e[m\n"
    ## The expression not expanding is intentional.
    # shellcheck disable=2016 # The expression not expanding is intentional.
	printf "  Color escapes are %s\n" '\e[${value};... ;${value}m'
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
		done; echo; echo
	done
}
###########################################

## Wrapping Display-Environment data/cmds:
##########################################
    ## Pull wallpaper location from nitrogen's config:
    ## usage: 'get_nitrogen_wallpaper'
    ##################################################
    get_nitrogen_wallpaper() {
        local nitrogen_conf=~/.config/nitrogen/bg-saved.cfg
        cmd_exists nitrogen && ( file_exists $nitrogen_conf || return 1 ) || return 1
        local nitrogen_wall=""; nitrogen_wall=$( sed -n 's/^file=//p' $nitrogen_conf | head -n 1 )
        ! str_empty "$nitrogen_wall" && ( echo "$nitrogen_wall" && return 0); return 1
    }
    ##################################################

    ## Pull wallpaper location from cinnamon's dconf config:
    ## usage: 'get_dconf_wallpaper'
    ########################################################
    get_dconf_wallpaper() {
        cmd_exists gsettings || return 1
        local cinnamon_wall=""; cinnamon_wall=$( gsettings get org.cinnamon.desktop.background picture-uri | sed 's/\x27//g; s/file\:\/\///g' )
        ! str_empty "$cinnamon_wall" && file_exists "$cinnamon_wall" && echo "$cinnamon_wall" && return 0; return 1
    }
    ########################################################

    ## Get & Set wallpaper ENV var from other sources:
    ## usage: 'define_wallpaper_var'
    ##################################################
    define_wallpaper_var() {
        local cmd_output
        cmd_output=$(get_dconf_wallpaper) || cmd_output=$(get_nitrogen_wallpaper) || return 1
        export WALLPAPER=${cmd_output} && return 0 || return 1
    }; alias define_wallpaper='define_wallpaper_var'
    ##################################################
##########################################

## Link to user scripts bash_aliases_scripts file:
# shellcheck source=src/Documents/Scripts/.bash_aliases_scripts
link_source $SRC_BASH_ALIASES_SCRIPTS


#
## END_FILE
