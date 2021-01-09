#!/bin/bash
# bashrc Config File:
#   location: ~/.SRC_BASHRC
#   author: t3@pfaffe.me  🄯2020-01/05/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Heavy modification from Manjaro's default .bashrc:
#   [bashrc]( https://gitlab.manjaro.org/packages/core/bash/-/blob/master/dot.bashrc ).


##########################
### INITIALIZE_BASHRC: ####################################################
##########################

SRC_BASHRC=~/.bashrc
SRC_BASH_ALIASES=~/.bash_aliases
SRC_BASH_COMPLETION=/usr/share/bash-completion/bash_completion

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


## Notify of an error in the bash configuration:
notify_err () {
    printf "[${COLOR_ALRT}Warning${COLOR_NC}]: Bash config file %s has errors!\n" "$1"
}

## Notify of an error in the bash configuration:
notify_link_err () {
    printf "[${COLOR_ALRT}Warning${COLOR_NC}]: Bash config file %s was not linked!\n" "$1"
}

## Notify of an change in the bash configuration:
notify_reload () {
    printf '[Notice: Reloaded bash configuration %s]\n - - - - -\n' "$1"
}

cmd_exists () {
    command -v "$1" >/dev/null && return 0 || return 1
}

file_exists () {
     [ -f "$1" ] >/dev/null && return 0 || return 1
}

str_empty () {
    [[ -z "${1// }" ]] && return 0 || return 1
}

bash_string_escape () {
# [src]( https://github.com/bitrise-io/steps-utils-bash-string-escaper/blob/master/bash_string_escape.sh )

  local arg="$1"
  local escapedvar=""

  if [[ "$2" == "--no-space" ]]; then
    escapedvar=$(echo "${arg}" | sed -e 's/[^][ a-zA-Z0-9/.:?,;(){}<>=*+-]/\\&/g' )
  else
    escapedvar=$(echo "${arg}" | sed -e 's/[^][a-zA-Z0-9/.:?,;(){}<>=*+-]/\\&/g'  )
  fi

  echo "${escapedvar}"
}

bash_lint () {
    cmd_exists shellcheck || return 1
    if str_empty "$1"; then local args='error'; else local args="$1" ; fi
    shellcheck -S "$args" ~/.bash{rc,_!(*history)} && return 0 || return 1
}

# valid options <error | warning | info | style>
bash_lint_full () {
    if str_empty "$1"; then local args='warning'; else local args="$1" ; fi
    printf "Checking bash config files for issues up to severity \'$args\'...\n"
    bash_lint "$args" && printf "\t<no issues found>"
    printf "\n done.\n"
    return 0
}

####################
### USER_CONFIG: ##########################################################
####################
## User specific environment variables.

# Set vars for default terminal
export TERMINAL='termite'
export TERM=$TERMINAL
export XDG_TERMINAL=$TERMINAL

# Set vars for default text-editors
export VISUAL='micro'
export EDITOR='nano'

# Set vars for Ranger
#export RANGERCD=true
#export AUTOCD="$(realpath "$1")"


#####################
### BASH_THEMING: #########################################################
#####################
## Text color & styling configuration.

# Enable/Disable color options
USE_COLOR=true

## Define colorizing escape sequences:
######################################
# Set No Color
export COLOR_NC='\e[0m'
alias  COLOR_RESET='tput sgr0'

if ${USE_COLOR} ; then
    export COLOR_PRI='\033[38;5;71m'
    export COLOR_SEC='\e[32m'
    export COLOR_ALRT='\e[31m'

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

    ## Pre-formatted some vars for use in convoluted strings:
    # shellcheck disable=2034
    FORM_COLOR_NC=${COLOR_NC}
    FORM_COLOR_PRI=${COLOR_PRI}
    FORM_COLOR_ALRT=${COLOR_ALRT}
    #FORM_COLOR_SEC=${COLOR_SEC}
    #FORM_COLOR_BLACK=${COLOR_BLACK}
fi


# Define Title Bar for PS1 and Window Titles
TITLEBAR='[\u@\h \w]'


##Set colorful PS1 only on colorful terminals:
##############################################
## Find dircolors database:
get_dircolors () {
    file_exists  ~/.dir_colors   && cat ~/.dir_colors   && return 0
    file_exists  /etc/DIR_COLORS && cat /etc/DIR_COLORS && return 0
    cmd_exists   dircolors       && dircolors --print-database   && return 0
    return 1 # return fail state
}
# Get output of dircolors database
dircolors_out=$(get_dircolors)


## Detect if using colorful terminal:
#safe_term=${TERM//[^[:alnum:]]/?}
if [[ $'\n'${dircolors_out} == *$'\n'"TERM "${TERM//[^[:alnum:]]/?}* ]]; then
    # $USE_COLOR || USE_COLOR=true

    TITLEBAR="${FORM_COLOR_PRI}[${FORM_COLOR_PRI}\u${FORM_COLOR_NC}@${FORM_COLOR_PRI}\h ${FORM_COLOR_PRI}\w]:${FORM_COLOR_NC}"
    TITLEBAR_ROOT="${FORM_COLOR_PRI}[${FORM_COLOR_ALRT}\u${FORM_COLOR_NC}@${FORM_COLOR_PRI}\h ${FORM_COLOR_PRI}\w]:${FORM_COLOR_NC}"

    if [[ ${EUID} == 0 ]] ; then    # User is root.
		PS1="${TITLEBAR_ROOT}\$ \[\033[0m\]"
	else                            # User is not root.
        PS1="\[${FORM_COLOR_PRI}\][\u\[${FORM_COLOR_NC}\]@\\[${FORM_COLOR_PRI}\]\h \[${FORM_COLOR_PRI}\]\w]:\[${FORM_COLOR_NC}\]\$ \[\033[0m\]"
	fi

else
    # echo "debug: no colors!!"
    # Set PS1 without color
    PS1="${TITLEBAR}\$ "
fi


if ${USE_COLOR} ; then

	# Enable colors for ls, etc.  Prefer ~/.dir_colors
	if cmd_exists dircolors ; then
		if file_exists ~/.dir_colors ; then
			eval "$(dircolors -b ~/.dir_colors)"
		elif file_exists /etc/DIR_COLORS ; then
			eval "$(dircolors -b /etc/DIR_COLORS)"
		fi
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
	alias dmesg='dmesg --color'
	alias less='less -r'
fi

# Cleanup variables used
unset safe_term dircolors_out

## Define default PS1 (aka. bash prompt prefix)
# cmd_exists $PS1 || PS1="${TITLEBAR}\$ "
PS2=">> "
PS3=">  "
PS4=">+ "

##############################################

## Change the window title of X terminals:
# TODO: fix for ssh.
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*|termite*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac


##Define & print Interactive Shell's MOTD
##########################################
motd_short () {
	local hostName="";    hostName=$(uname -n)
	local kernelVer="";   kernelVer=$(uname -r)
	local currentTime=""; currentTime=$(date +%m/%d/%C-%H:%M)

	printf "%s" $hostName
	printf "@"
	printf "Arch-Linux_%s" ${kernelVer%-*-*}
	printf " - %s" $currentTime
	printf "\n"
}

motd_long () {
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

# Check for errors in config
bash_lint >/dev/null || notify_err "$SRC_BASHRC"

# Link bash_alias file:
#  shellcheck source=src/.bashrc
if file_exists $SRC_BASH_ALIASES ; then source $SRC_BASH_ALIASES || notify_link_err $SRC_BASH_ALIASES; fi

## Enable bash-completion:
#  shellcheck source=/dev/null
if file_exists $SRC_BASH_COMPLETION ; then source $SRC_BASH_COMPLETION || notify_link_err $SRC_BASH_COMPLETION; fi
complete -cf sudo

# Attempt to fetch xorg wallpaper
cmd_exists set_wallpaper_var && set_wallpaper_var

# Fail-over for reload_bash
# shellcheck disable=1090
cmd_exists rld || alias rld='source "${SRC_BASHRC}"'

# Print motd
motd_long

##<USER_PROMPT>##


#########################
### AUTO-GEN_APPENDS: ######################################################
#########################
## Usually added by install scripts and appended to this file.
# shellcheck disable=2090

PATH="/home/t3pfaffe/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/t3pfaffe/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/t3pfaffe/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base /home/t3pfaffe/perl5"; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/t3pfaffe/perl5"; export PERL_MM_OPT;
