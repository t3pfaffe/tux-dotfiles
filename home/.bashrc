#!/bin/bash
# bashrc Config File:
#   location: ~/.bashrc
#   author: t3@pfaffe.me  🄯2020-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Configuration (variable, alias, & function definitions) for all bash shells.
#    - Heavy modification from Manjaro's default .bashrc:
#      [bashrc]( https://gitlab.manjaro.org/packages/core/bash/-/blob/master/dot.bashrc ).



##########################
### INITIALIZE_BASHRC: ####################################################
##########################

## Ignore these error codes globally:
#shellcheck disable=SC2059

## Tag self as linked for dependents:
# shellcheck disable=2034
HAS_BASHRC=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Define Used Files:
SRC_BASHRC=~/.bashrc
SRC_BASH_UTILS=~/.scripts/bash_utils.sh
SRC_BASH_ALIASES=~/.bash_aliases
SRC_BASH_COMPLETION=/usr/share/bash-completion/bash_completion
SRC_BASH_DEBUG_UTILS=~/.scripts/bash_debug_utils.sh

## Script sourcing function:
# shellcheck disable=1090,2086
if ! command -v link_source &>/dev/null ; then link_source () { [[ -f $1 ]] && source $1 || echo "Failed to link ${1}!!"; } ; fi

## Link bash utilities
link_source $SRC_BASH_UTILS
link_source $SRC_BASH_DEBUG_UTILS

#######################
### MASTER_TOGGLES: #######################################################
#######################

## Enable/Disable color options:
export USE_BASH_COLOR=true

## Enable/Disable what debug levels are displayed:
safe_export USE_BASH_DEBUG_LVL_ERRORS true   # Critical ERRORS that *will* impact necessary functionality.
safe_export USE_BASH_DEBUG_LVL_WARNINGS true # Noncritical WARNINGS that *may* impact desired functionality.
safe_export USE_BASH_DEBUG_LVL_INFO true     # Noncritical INFO on the bash configuration that *wont* impact functionality.

## Enable/Disable clearing logs after init:
export BASH_DEBUG_CLR_INIT=true

##########################
### SETUP_MSGS_BUFFER: ####################################################
##########################

## Log messages in buffer for MOTD:

## Define bash initialization messages buffer:
declare -a INIT_MSGS_BASH_LOG

## Append arguments to init-msgs buffer
append_init_msgs() {
    local args="$*" ; str_empty "$args" && return 1
    INIT_MSGS_BASH_LOG=("${INIT_MSGS_BASH_LOG[@]}" "$args")
}

reset_init_msgs() {
    unset INIT_MSGS_BASH_LOG ; declare -ag INIT_MSGS_BASH_LOG
}


####################
### USER_CONFIG: ##########################################################
####################
## User specific environment variables.

## Set vars for default terminal:
safe_export TERM 'alacritty'
safe_export TERMINAL "${TERM}"
safe_export XDG_TERMINAL "${TERMINAL}"

## Set vars for default text-editors:
export VISUAL='micro'
export EDITOR='nano'

## Set vars for Ranger:
#export RANGERCD=true
#export AUTOCD="$(realpath "$1")"


## Define colorizing escape sequences:
######################################
## Set Default 'No-Color'
export COLOR_NC='\e[0m'
alias  COLOR_RESET='tput sgr0'

## Set Basic Colors
export COLOR_BLACK='\e[0;30m'
export COLOR_RED='\e[0;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_YELLOW='\e[0;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_CYAN='\e[0;36m'
export COLOR_WHITE='\e[0;0m'

## Set Bold Modified Basic Colors
export COLOR_BLD_RED='\e[1;31m'
export COLOR_BLD_GREEN='\e[1;32m'
export COLOR_BLD_YELLOW='\e[1;33m'
export COLOR_BLD_BLUE='\e[1;34m'
export COLOR_BLD_PURPLE='\e[1;35m'
export COLOR_BLD_CYAN='\e[1;36m'
export COLOR_BLD_WHITE='\e[1m'

## TODO: figure out what to do w/ these
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_GRAY='\e[1;30m'

## Set Main Theme Colors:
export COLOR_PRI='\033[38;5;71m'
export COLOR_SEC='\e[32m'

## Debug Colors:
export COLOR_ALRT='\e[1;31m'
export COLOR_WARN='\e[1;33m'

## Modifiers:
export TXT_BOLD='\e[1m'

## Reformat of common colors for use in bash PS* prompts:
FCLR_NC='\['"${COLOR_NC}"'\]'
FCLR_PRI='\['"${COLOR_PRI}"'\]'
FCLR_SEC='\['"${COLOR_NC}"'\]'
FCLR_ALRT='\['"${COLOR_ALRT}"'\]'
######################################



#####################
### BASH_THEMING: #########################################################
#####################
## Text color & styling configuration.

## Dispaly Subshell lvl if nested:
SUBSHELL_LVL=""; [ $SHLVL -gt 1 ] && SUBSHELL_LVL="↳ ${SHLVL}"
FORM_SUBSHELL_LVL=""; [ $SHLVL -gt 1 ] && FORM_SUBSHELL_LVL="(↳ ${SHLVL})"

# Define Title Bar for PS1 and Window Titles
TITLEBAR="${USER}@${HOSTNAME%%.*}: ${PWD/#$HOME/\~}/"
PS_TITLEBAR='[\u@\h \w]:$ '

PS_PROMPT="\[\033[0m\]${FCLR_SEC}${SUBSHELL_LVL}${FCLR_PRI}[\u${FCLR_SEC}@${FCLR_PRI}\h ${FCLR_PRI}\w/]:${FCLR_NC}\$ \[\033[0m\]"
PS_PROMPT_NC=$PS_TITLEBAR
PS_PROMPT_ROOT="\[\033[0m\]${FCLR_SEC}${SUBSHELL_LVL}${FCLR_PRI}[\u${FCLR_SEC}@${FCLR_ALRT}\h ${FCLR_ALRT}\w]:${FCLR_NC}\$ \[\033[0m\]"
PS_PROMPT_ROOT_NC=$PS_TITLEBAR

## TODO: filter out color escapes when usecolor is false
# Use RegEx: /\\\[\\(e|[0-9]{3})\[(.{1,5}m)\\\]/ig ; Which results in: [\u@\h \w]:$
# [ref]( https://regex101.com/r/ncLX6R/1 )
rm_prompt_clrs() {
    PS_PROMPT=$PS_PROMPT_NC ; PS_PROMPT_ROOT=$PS_PROMPT_ROOT_NC
}

if ${USE_BASH_COLOR} ; then

    ## Find dircolors database:
    get_dircolors () {
        file_exists  ~/.dir_colors   && cat ~/.dir_colors   && return 0
        file_exists  /etc/DIR_COLORS && cat /etc/DIR_COLORS && return 0
        cmd_exists   dircolors       && dircolors --print-database   && return 0
        return 1 # return fail state
    }

    # Get output of dircolors database
    dircolors_out=$(get_dircolors)

	## Define colors for cmds like ls & etc:
	##  Prefers ~/.dir_colors config file.
    set_dircolors () {
	    if cmd_exists dircolors ; then
		    if file_exists ~/.dir_colors ; then
			    eval "$(dircolors -b ~/.dir_colors)"
		    elif file_exists /etc/DIR_COLORS ; then
			    eval "$(dircolors -b /etc/DIR_COLORS)"
		    fi
	    fi
	}

    # Set dircolors from config
    set_dircolors

    ## Alias cmds so that they show dircolors:
	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
	alias dmesg='dmesg --color'
	alias less='less -r'

	#Set colorful PS1 only on colorful terminals:
	if ! [[ $'\n'${dircolors_out} == *$'\n'"TERM "${TERM//[^[:alnum:]]/?}* ]] ; then
		rm_prompt_clrs
    fi

	# Cleanup variables used
	unset dircolors_out
else
    rm_prompt_clrs
fi

## Set the PS1 Prompt:
if [[ ${EUID} == 0 ]] ; then    # User is root.
	PS1=$PS_PROMPT_ROOT
else                            # User is not root.
    PS1=$PS_PROMPT
fi

## Define the other default Prompts:
PS2=">> "
PS3="LN ${LINENO} >  "
PS4="LN ${LINENO} >+ "

## Change the window title of X terminals:
#########################################
# TODO: fix for ssh.
case ${TERM} in
	alacritty*|termite*|xterm*|rxvt*|Eterm*|konsole*|gnome*|aterm|kterm|interix)
		PROMPT_COMMAND='echo -en "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\a"'
    ;;
	screen*)
		PROMPT_COMMAND='echo -en "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac
#########################################

##Define & print Interactive Shell's MOTD
####################################
motd_notices() {
    local ln=

    ## Check and append log entries to msg buffer.
    if $USE_BASH_DEBUG_LVL_INFO     ; then INIT_MSGS_BASH_LOG+=( "${DEBUG_INFO_BASH_LOG[@]}" )    ; fi
    if $USE_BASH_DEBUG_LVL_WARNINGS ; then INIT_MSGS_BASH_LOG+=( "${DEBUG_WARNING_BASH_LOG[@]}" ) ; fi
    if $USE_BASH_DEBUG_LVL_ERRORS   ; then INIT_MSGS_BASH_LOG+=( "${DEBUG_ERROR_BASH_LOG[@]}" )  ; fi

    # Exit if there is no messages in the buffer:
    if [ ${#INIT_MSGS_BASH_LOG[@]} -eq 0 ] ; then return 1 ; fi

    ## Print out messages in buffer
    for ln in "${INIT_MSGS_BASH_LOG[@]}" ; do
      str_empty "$ln" || printf "\n%s" "$ln"
    done ; printf "\n- - - - - - - - \n"

    # Clear message buffer after printing ;
    reset_init_msgs
    $BASH_DEBUG_CLR_INIT && reset_debug_logs

}
motd_short() {

	local hostName="" ;    hostName=$(uname -n)
	local kernelVer="" ;   kernelVer=$(uname -r)
	local currentTime="" ; currentTime="$(date +%m/%d/%C) $(date +%H:%M)"

	printf "%s" "$hostName"
	printf "@"
	printf "Arch-Linux_%s" "${kernelVer%-*-*}"
	printf " - %s" "$currentTime"
	printf "\n"
}
motd_long() {

    # Print any errors/notices ahead of the MOTD
    motd_notices
    ## Print motd header and prepend the bash_version:
    printf "(Bash_%s) " "${BASH_VERSION%(*}"
    motd_short
}
# Shortcut to print motd
alias motd='motd_short'
##########################################


################
### STARTUP: ###############################################################
################
## Configure bash options & run whatever necessary
#   prior to terminal user input.

# Enable (-s) or Disable (-u) bash aliases
shopt -s expand_aliases

# Enable (-s) or Disable (-u) history appending
#  instead of overwriting.
shopt -s histappend

# Enable (-s) or Disable (-u) checking terminal
#  size on refocus.
shopt -s checkwinsize

# Prevent Ctrl+S Freezing Terminal
stty -ixon

# Check for errors in config before linking
bash_lint >/dev/null || debug_notify_syntax_err "$SRC_BASHRC"

# Link bash_alias file:
#  shellcheck source=./.bash_aliases
link_source $SRC_BASH_ALIASES

## Enable bash-completion:
#  shellcheck source=./.scripts/.bash_aliases_scripts
link_source $SRC_BASH_COMPLETION
complete -cf sudo

## Attempt to fetch xorg wallpaper
cmd_exists define_wallpaper_var && define_wallpaper_var

## Fallback reloading alias for bash:
cmd_exists reload_bash || ( ( alias reload_bash=' cls ; source $(SRC_BASHRC) ' && alias rld='reload_bash' ) ; debug_notify_link_err $SRC_BASHRC )

## Debug Functionality Test:
#debug_notify_info "testing  notify_info !"
# debug_notify_warn "testing  notify_warn !"
# debug_notify_err  "testing notify_error !"

##Print MOTD
motd_long


#########################
### AUTO-GEN_APPENDS: ######################################################
#########################
## Usually added by install scripts and appended to this file.
##

