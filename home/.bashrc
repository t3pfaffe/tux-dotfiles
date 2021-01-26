#!/bin/bash
# bashrc Config File:
#   location: ~/.bashrc
#   author: t3@pfaffe.me  🄯2020-01/05/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   - Is the first bash config file for loaded
#       non-interactive shells.
#   - Ultimately loaded in both non-interactive
#      and interactive shells.
#   Heavy modification from Manjaro's default .bashrc:
#   [bashrc]( https://gitlab.manjaro.org/packages/core/bash/-/blob/master/dot.bashrc ).


# If not running interactively, don't do anything
[[ $- != *i* ]] && return


#######################
### MASTER_TOGGLES: #######################################################
#######################

## Enable/Disable color options:
export USE_BASH_COLOR=true

## Enable/Disable what debug levels are displayed:
export USE_BASH_DEBUG_LVL_ERRORS=true     # Critical ERRORS that *will* impact necessary functionality.
export USE_BASH_DEBUG_LVL_WARNINGS=true  # Noncritical WARNINGS that *may* impact desired functionality.
export USE_BASH_DEBUG_LVL_INFO=true       # Noncritical INFO on the bash configuration that *wont* impact functionality.


##############################
### DEFINE_BASH_FUNCTIONS: ################################################
##############################

## Useful shell functions:
##########################
## TODO: move to another modular file?

## Returns true if provided command(s) exist(s)
cmd_exists () {
     for arg in "$@" ; do command -v "$1" >/dev/null || return 1 ; done ; return 0
}

## Returns true if provided file(s) exists
file_exists () {
    for arg in "$@" ; do [ -f "$1" ] >/dev/null || return 1 ; done ; return 0
}

## Returns true if provided environment variables (s) exist(s).
var_exists () {
    str_empty "$1" && return 1
    if [[ -v $1 ]] ; then  return 0 ; elif ! [[ -z "${1}" ]] ; then return 0 ; else return 1 ; fi
}

## Returns true if provided string(s) exist(s).
str_empty () {
    for arg in "$@" ; do [[ -z "${arg// }" ]] || return 1 ; done ; return 0
}

## Internalizes variables only if they do not already exist
#set_var_safe () {
#    var_exists "$1" && return 1
#    export arg_var_name="${1}=${2}"
#    echo "$arg_var_name"
#}
##########################

## Log messages in buffer for MOTD:
###################################
## TODO: move to another modular file?
## Define bash initialization messages buffer:
declare -a INIT_MSGS_BASH_LOG

## Append arguments to init-msgs buffer
append_init_msgs () {
    local args="$*"; str_empty "$args" && return 1
    INIT_MSGS_BASH_LOG=("${INIT_MSGS_BASH_LOG[@]}" "$args")
}
###################################

## Debug log functions:
#######################
## TODO: move to another modular file?

#set_var_safe BASH_TEST_1 "'empty'"
#set_var_safe BASH_TEST_1 "'empty222'"

## Default options for log level:
var_exists $USE_BASH_DEBUG_LVL_ERRORS   || export USE_BASH_DEBUG_LVL_ERRORS=true
var_exists $USE_BASH_DEBUG_LVL_WARNINGS || export USE_BASH_DEBUG_LVL_WARNINGS=false
var_exists $USE_BASH_DEBUG_LVL_INFO     || export USE_BASH_DEBUG_LVL_INFO=true

## Define & initialize bash debug log:
var_exists DEBUG_ERROR_BASH_LOG || declare -a DEBUG_ERROR_BASH_LOG
var_exists DEBUG_WARNING_BASH_LOG || declare -a DEBUG_WARNING_BASH_LOG
var_exists DEBUG_INFO_BASH_LOG || declare -a DEBUG_INFO_BASH_LOG

## Default debug text colors:
var_exists  $COLOR_ALRT || export COLOR_ALRT='\e[31m'
var_exists  $COLOR_WARN || export COLOR_WARN='\e[1;33m'
var_exists  $COLOR_NC   || export COLOR_NC='\e[0m'

## Append argument to log
debug_append_err () {
    local args="$*"; str_empty "$args" && return 1
    DEBUG_ERROR_BASH_LOG+=("$args")
}

## Append argument to log
debug_append_warn () {
    local args="$*"; str_empty "$args" && return 1
    DEBUG_WARN_BASH_LOG+=("$args")
}

## Append arguments to log
debug_append_info () {
    local args="$*"; str_empty "$args" && return 1
    DEBUG_INFO_BASH_LOG+=("$args")
}

## Notify of an error in the bash configuration:
debug_notify_syntax_err () {
    debug_append_err "$(printf "[${COLOR_ALRT}Warning${COLOR_NC}]: Bash config file %s has errors!" "$1")"
}

## Notify of an error while linking another bash configuration file:
debug_notify_link_err () {
    debug_append_err "$(printf "[${COLOR_ALRT}Warning${COLOR_NC}]: Bash config file %s was not linked!" "$1")"
}

## Notify of an error while linking another non-vital bash configuration file:
debug_notify_link_warn () {
    debug_append_warn "$(printf "[${COLOR_WARN}Warning${COLOR_NC}]: Bash config file %s was not linked!" "$1")"
}

## Notify of an error while linking another non-vital bash configuration file:
debug_notify_info () {

    debug_append_info "$(printf "[${COLOR_WARN}Warning${COLOR_NC}]: %s " "$1")"
}



## Notify of an change in the bash configuration:
notify_reload () {
    local args=''; str_empty "$1" || local args="from file ${1}"
    debug_append_info "$(printf "[${COLOR_PRI}Notice${COLOR_NC}]: Reloaded bash configuration %s ." "$args")"
}

reset_debug_logs () {
    unset DEBUG_ERROR_BASH_LOG
    declare -a DEBUG_ERROR_BASH_LOG
    unset DEBUG_WARNING_BASH_LOG
    declare -a DEBUG_WARNING_BASH_LOG
    unset DEBUG_INFO_BASH_LOG
    declare -a DEBUG_INFO_BASH_LOG
}
#######################


## Return strings with escaped characters for printf:
##  [src]( https://github.com/bitrise-io/steps-utils-bash-string-escaper/blob/master/bash_string_escape.sh )
#####################################################
bash_string_escape () {

  local arg="$1"
  local escapedvar=""

  if [[ "$2" == "--no-space" ]]; then
    escapedvar=$(echo "${arg}" | sed -e 's/[^][ a-zA-Z0-9/.:?,;(){}<>=*+-]/\\&/g' )
  else
    escapedvar=$(echo "${arg}" | sed -e 's/[^][a-zA-Z0-9/.:?,;(){}<>=*+-]/\\&/g'  )
  fi

  echo "${escapedvar}"
}
#####################################################

bash_lint () {
    cmd_exists shellcheck || return 1
    if str_empty "$1"; then local args='error'; else local args="$1" ; fi
    shellcheck -S "$args" ~/.bash{rc,_!(*history)} && return 0 || return 1
}

# valid args: <error | warning(default) | info | style>
bash_lint_full () {
    if str_empty "$1"; then local args='warning'; else local args="$1" ; fi
    printf "Checking bash config files for issues up to severity \'%s\'...\n" "$args"
    bash_lint "$args" && printf "\t<no issues found>"
    printf "\n done.\n"
    return 0
}


####################
### USER_CONFIG: ##########################################################
####################
## User specific environment variables.

# Set vars for default terminal:
export TERMINAL='termite'
export TERM=$TERMINAL
export XDG_TERMINAL=$TERMINAL

## Set vars for default text-editors:
export VISUAL='micro'
export EDITOR='nano'

## Set vars for Ranger:
#export RANGERCD=true
#export AUTOCD="$(realpath "$1")"


##########################
### INITIALIZE_BASHRC: ####################################################
##########################

## Define Used Files:
SRC_BASHRC=~/.bashrc
SRC_BASH_ALIASES=~/.bash_aliases
SRC_BASH_COMPLETION=/usr/share/bash-completion/bash_completion


## Define colorizing escape sequences:
######################################
## Set Default 'No-Color'
export COLOR_NC='\e[0m'
alias  COLOR_RESET='tput sgr0'

## Set Basic Colors
export COLOR_BLACK='\e[30m'
export COLOR_GRAY='\e[1;30m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_WHITE='\e[1;37m'

## Set Main Theme Colors:
export COLOR_PRI='\033[38;5;71m'
export COLOR_SEC='\e[32m'

## Debug Colors:
export COLOR_ALRT='\e[31m'
export COLOR_WARN=$COLOR_YELLOW
######################################


#####################
### BASH_THEMING: #########################################################
#####################
## Text color & styling configuration.



# Define Title Bar for PS1 and Window Titles
TITLEBAR='[\u@\h \w]'
## Define the other default Prompts
PS2=">> "
PS3="LN ${LINENO} >  "
PS4="LN ${LINENO} >+ "

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

    ##Set colorful PS1 only on colorful terminals:
    if [[ $'\n'${dircolors_out} == *$'\n'"TERM "${TERM//[^[:alnum:]]/?}* ]] ; then

        ## Formatted some vars for use in convoluted strings:
        FORM_COLOR_NC=${COLOR_NC}
        FORM_COLOR_PRI=${COLOR_PRI}
        FORM_COLOR_ALRT=${COLOR_ALRT}

        TITLEBAR="${FORM_COLOR_PRI}[${FORM_COLOR_PRI}\u${FORM_COLOR_NC}@${FORM_COLOR_PRI}\h ${FORM_COLOR_PRI}\w]:${FORM_COLOR_NC}"
        TITLEBAR_ROOT="${FORM_COLOR_PRI}[${FORM_COLOR_ALRT}\u${FORM_COLOR_NC}@${FORM_COLOR_PRI}\h ${FORM_COLOR_PRI}\w]:${FORM_COLOR_NC}"

        if [[ ${EUID} == 0 ]] ; then    # User is root.
	        PS1="${TITLEBAR_ROOT}\$ \[\033[0m\]"
        else                            # User is not root.
            PS1="\[${FORM_COLOR_PRI}\][\u\[${FORM_COLOR_NC}\]@\\[${FORM_COLOR_PRI}\]\h \[${FORM_COLOR_PRI}\]\w]:\[${FORM_COLOR_NC}\]\$ \[\033[0m\]"
        fi
    fi

else
    # Set PS1 without color
    PS1="${TITLEBAR}\$ "
fi

# Cleanup variables used
unset dircolors_out
##############################################

## Change the window title of X terminals:
#########################################
# TODO: fix for ssh.
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*|termite*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac
#########################################

##Define & print Interactive Shell's MOTD
####################################
motd_notices() {

    ## Check and append log entries to msg buffer.
    if $USE_BASH_DEBUG_LVL_INFO     ; then INIT_MSGS_BASH_LOG+=( "${DEBUG_INFO_BASH_LOG[@]}" )    ; fi
    if $USE_BASH_DEBUG_LVL_WARNINGS ; then INIT_MSGS_BASH_LOG+=( "${DEBUG_WARNING_BASH_LOG[@]}" ) ; fi
    if $USE_BASH_DEBUG_LVL_ERRORS   ; then INIT_MSGS_BASH_LOG+=( "${DEBUG_ERROR_BASH_LOG[@]}" )  ; fi

    if [ ${#INIT_MSGS_BASH_LOG[@]} -eq 0 ]; then return 1 ; fi ## msg bufff empty, exiting.

    for ln in "${INIT_MSGS_BASH_LOG[@]}" ; do
      str_empty $ln || printf "\n%s" "$ln"
    done

    printf "\n- - - - - - - - \n"

    ## Clear buffer after printing;
    unset INIT_MSGS_BASH_LOG
    declare -a INIT_MSGS_BASH_LOG
}
motd_short () {

	local hostName="";    hostName=$(uname -n)
	local kernelVer="";   kernelVer=$(uname -r)
	local currentTime=""; currentTime=$(date +%m/%d/%C-%H:%M)

	printf "%s" $hostName
	printf "@"
	printf "Arch-Linux_%s" ${kernelVer%-*-*}
	printf " - %s" "$currentTime"
	printf "\n"
}
motd_long () {

    motd_notices

    printf "(Bash_%s) " ${BASH_VERSION%(*}

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
#  shellcheck source=src/.bashrc
if file_exists $SRC_BASH_ALIASES ; then source $SRC_BASH_ALIASES || debug_notify_link_err $SRC_BASH_ALIASES ; fi

## Enable bash-completion:
#  shellcheck source=src/.scripts/.bash_aliases_scripts
if file_exists $SRC_BASH_COMPLETION ; then source $SRC_BASH_COMPLETION || debug_notify_link_err $SRC_BASH_COMPLETION ; fi
complete -cf sudo

## Attempt to fetch xorg wallpaper
cmd_exists define_wallpaper_var && define_wallpaper_var

## Fallback reloading alias for bash:
# shellcheck disable=1090
if ! cmd_exists reload_bash ; then ( alias reload_bash=' cls; source $(SRC_BASHRC) ' && alias rld='reload_bash'; debug_notify_link_err $SRC_BASHRC ) ; fi


##Print MOTD
motd_long

##<USER_PROMPT>##


#########################
### AUTO-GEN_APPENDS: ######################################################
#########################
## Usually added by install scripts and appended to this file.
##

## Perl ENV Setup:
##################
# shellcheck disable=2090
PATH="/home/t3pfaffe/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/t3pfaffe/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/t3pfaffe/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base /home/t3pfaffe/perl5"; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/t3pfaffe/perl5"; export PERL_MM_OPT;
##################
source "$HOME/.cargo/env"
