#!/bin/bash
# bashrc Config File:
#   location: ~/.bashrc
#   author: t3@pfaffe.me  🄯2020-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Configuration (variable, alias, & function definitions) for all bash shells.
#    - Heavy modification from Manjaro's default ~/.bashrc:
#      [~/.bashrc](https://gitlab.manjaro.org/packages/core/bash/-/blob/master/dot.bashrc).



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

## Enable/Disable printing a motd on new terminal session:
safe_declare BASH_DO_SHOW_MOTD '=true'

## Enable/Disable logging to msg buffer during init:
safe_declare BASH_DO_ILOG '=true'

## Enable/Disable colorizing of terminal output:
safe_declare BASH_DO_SHOW_COLOR '=true'

## Enable/Disable clearing vars after init:
safe_declare BASH_DEBUG_DO_CLEANUP_VARS '=true'
## Enable/Disable clearing logs after init:
safe_declare BASH_DEBUG_DO_CLEANUP_LOGS '=true'
## Enable/Disable Performing lint check and initialization:
safe_declare BASH_DEBUG_DO_LINT '=false'

## Enable/Disable what debug levels are displayed:
if [ "$BASH_DO_ILOG" ]; then
    declare -r USE_BASH_DEBUG_LVL_ERRORS=true    2>/dev/null    # Critical ERRORS that *will* impact necessary functionality.
    declare -r USE_BASH_DEBUG_LVL_WARNINGS=true 2>/dev/null    # Non-critical WARNINGS that *may* impact desired functionality.
    declare -r USE_BASH_DEBUG_LVL_INFO=true      2>/dev/null    # Non-critical INFO on the bash configuration that *wont* impact functionality.
else
    declare -r USE_BASH_DEBUG_LVL_ERRORS=false   2>/dev/null
    declare -r USE_BASH_DEBUG_LVL_WARNINGS=false 2>/dev/null
    declare -r USE_BASH_DEBUG_LVL_INFO=false     2>/dev/null
fi;

## Attempt unset of provided variable names:
try_unset() {
    $BASH_DEBUG_DO_CLEANUP_VARS && unset "$@"
}

##########################
### SETUP_MSGS_BUFFER: ####################################################
##########################
## Log messages in buffer for MOTD:


## Define bash initialization messages buffer:
declare -a INIT_MSGS_BASH_LOG

## Append arguments to init-msgs buffer
append_init_msgs() {
    $BASH_DO_ILOG || return 0; str_empty "$*" && return 1

    INIT_MSGS_BASH_LOG=("${INIT_MSGS_BASH_LOG[@]}" "$*")
}

reset_init_msgs() {
    $BASH_DEBUG_DO_CLEANUP_VARS && unset INIT_MSGS_BASH_LOG ; declare -ag INIT_MSGS_BASH_LOG
}


####################
### USER_CONFIG: ##########################################################
####################
## User specific environment variables.

## Set vars for default terminal:
safe_export TERM 'xterm-256color'
safe_export TERMINAL "${TERM}"
safe_export XDG_TERMINAL "${TERMINAL}"

## Set vars for default text-editors:
export VISUAL='micro'
export EDITOR='nano'

## Set vars for Ranger:
#export RANGERCD=true
#export AUTOCD="$(realpath "$1")"


## Define colorizing escape sequences:
#####################################

    ## Set 'No-Color'
    export COLOR_NC='\e[0m'

    ## Set Alternate 'No-Color'
    alias reset_color='tput sgr0'

    ## Type Modifiers:
    declare TXT_BOLD='\e[1m'     # Start bold
    declare TXT_BLNK='\e[5m'     # Start blinking
    declare TXT_SMUL='\e[4m'     # Start underline
    declare TXT_RMUL='\e[24m'    # End underline
    declare TXT_SMSO='\e[3m'     # Start 'standout'
    declare TXT_RMSO='\e[23m'    # End 'standout'

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
    declare COLOR_BLD_BLACK='\e[1;30m'
    declare COLOR_BLD_RED='\e[1;31m'
    declare COLOR_BLD_GREEN='\e[1;32m'
    declare COLOR_BLD_YELLOW='\e[1;33m'
    declare COLOR_BLD_BLUE='\e[1;34m'
    declare COLOR_BLD_PURPLE='\e[1;35m'
    declare COLOR_BLD_CYAN='\e[1;36m'
    declare COLOR_BLD_WHITE='\e[1m'

    ## Set Main Theme Colors:
    safe_export COLOR_PRI '\033[38;5;71m'
    safe_export COLOR_SEC '\e[32m'

    ## Debug Colors:
    safe_export COLOR_ALRT '\e[1;31m'
    safe_export COLOR_WARN '\e[1;33m'
#####################################


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

## Reformat of common colors for use in bash PS* prompts:
FCLR_NC='\['"${COLOR_NC}"'\]'
FCLR_PRI='\['"${COLOR_PRI}"'\]'
FCLR_SEC='\['"${COLOR_NC}"'\]'
FCLR_ALRT='\['"${COLOR_ALRT}"'\]'

## TODO: Filter out color escapes when color is disabled instead of keeping two different vars.
PS_PROMPT=$PS_TITLEBAR
PS_PROMPT_COLOR="\[\033[0m\]${FCLR_SEC}${SUBSHELL_LVL}${FCLR_PRI}[\u${FCLR_SEC}@${FCLR_PRI}\h ${FCLR_PRI}\w/]:${FCLR_NC}\$ \[\033[0m\]"
PS_PROMPT_ROOT=$PS_TITLEBAR
PS_PROMPT_ROOT_COLOR="\[\033[0m\]${FCLR_SEC}${SUBSHELL_LVL}${FCLR_PRI}[\u${FCLR_SEC}@${FCLR_ALRT}\h ${FCLR_ALRT}\w]:${FCLR_NC}\$ \[\033[0m\]"

if ${BASH_DO_SHOW_COLOR} ; then

    ## Find dircolors database:
    get_dircolors() {
        file_exists  ~/.dir_colors   && cat ~/.dir_colors   && return 0
        file_exists  /etc/DIR_COLORS && cat /etc/DIR_COLORS && return 0
        cmd_exists   dircolors       && dircolors --print-database   && return 0
        return 1 # return fail state
    }

	## Create new ~/.dir_colors if not present:
    create_dircolors_conf() {
	    if cmd_exists dircolors ; then
		    if file_exists ~/.dir_colors ; then
			    eval "$(dircolors -b ~/.dir_colors)"
		    elif file_exists /etc/DIR_COLORS ; then
			    eval "$(dircolors -b /etc/DIR_COLORS)"
		    fi
	    fi
	}

    # Set dircolors from config
    create_dircolors_conf
    # Get output of dircolors database
    dircolors_out=$(get_dircolors)


	#Set colorful PS1 only on colorful terminals:
	if [[ $'\n'${dircolors_out} == *$'\n'"TERM "${TERM//[^[:alnum:]]/?}* ]] ; then
        PS_PROMPT=$PS_PROMPT_COLOR ; PS_PROMPT_ROOT=$PS_PROMPT_ROOT_COLOR

        ## Alias cmds so that they show dircolors:
	    alias ls='ls --color=auto'
	    alias grep='grep --colour=auto'
	    alias egrep='egrep --colour=auto'
	    alias fgrep='fgrep --colour=auto'
	    alias dmesg='dmesg --color'
	    alias less='less -r'

    fi

	# Cleanup variables used
    try_unset get_dircolors create_dircolors_conf dircolors_out

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
##########################################

# TODO: fix for ssh.
case ${TERM} in
	alacritty*|termite*|xterm*|rxvt*|Eterm*|konsole*|gnome*|aterm|kterm|interix)
		PROMPT_COMMAND='echo -en "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\a"'
    ;;
	screen*)
		PROMPT_COMMAND='echo -en "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

## Cleanup variables used:
try_unset PS_PROMPT PS_PROMPT_ROOT PS_PROMPT_COLOR PS_PROMPT_ROOT_COLOR PS_TITLEBAR TITLEBAR SUBSHELL_LVL FORM_SUBSHELL_LVL
try_unset FCLR_NC FCLR_PRI FCLR_SEC FCLR_ALRT
##########################################

## Define & print Interactive Shell's MOTD:
##########################################
motd_notices() {
    "$BASH_DO_ILOG" || return 1

    ## Check and append log entries to msg buffer.
    $USE_BASH_DEBUG_LVL_INFO     && INIT_MSGS_BASH_LOG+=( "${DEBUG_INF_BASH_LOG[@]}")
    $USE_BASH_DEBUG_LVL_WARNINGS && INIT_MSGS_BASH_LOG+=( "${DEBUG_WRN_BASH_LOG[@]}")
    $USE_BASH_DEBUG_LVL_ERRORS   && INIT_MSGS_BASH_LOG+=( "${DEBUG_ERR_BASH_LOG[@]}")

    ## Check if there is no messages in the buffer:
    if [ ${#INIT_MSGS_BASH_LOG[@]} -ne 0 ]; then
        ## Print out messages in buffer:
        for ln in "${INIT_MSGS_BASH_LOG[@]}" ; do
          str_empty "$ln" || printf "\n%s" "$ln"
        done ; printf "\n- - - - - - - - \n"

    else
        $BASH_DEBUG_DO_CLEANUP_LOGS && reset_debug_logs
        return 1
    fi

    $BASH_DEBUG_DO_CLEANUP_LOGS && reset_debug_logs
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
    if motd_notices ; then
        # Clear message buffer after printing ;
        $BASH_DEBUG_DO_CLEANUP_LOGS && reset_init_msgs
    fi

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

## Note: shopt < -s (Enable) | -u (Disable)>

# Enable bash aliases
shopt -s expand_aliases

# Enable history append instead of overwriting
shopt -s histappend

# Enable checking terminal size on refocus
shopt -s checkwinsize

# Disable XOFF (aka Ctrl+S freeze)
stty -ixon

## Check for errors in config before linking:
$BASH_DEBUG_DO_LINT && ( bash_lint >/dev/null || debug_notify_syntax_err "$SRC_BASHRC" )

## Link bash_alias file:
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
# debug_notify_info  "TEST_1_INFO"
# debug_notify_warn  "TEST_2_WARN"
# debug_notify_error "TEST_3_ERROR"
# debug_notify_link_wrn "TEST_4_WARN"
# debug_notify_link_err  "TEST_5_ERROR"

##Print MOTD
$BASH_DO_SHOW_MOTD && motd_long


#####################
### LINK_APPENDS: ##########################################################
#####################
## Usually added by install scripts and appended to this file.
##


# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

## Rust ENV Setup:
cmd_exists /usr/bin/cargo && link_source "$HOME/.cargo/env" && export CARGO_HOME="$HOME/.cargo/"

## Ruby ENV Setup:
cmd_exists /usr/bin/gem && GEM_HOME="$(ruby -e 'puts Gem.user_dir')"; export GEM_HOME && export PATH="$PATH:$GEM_HOME/bin"
