#!/bin/bash
# bash_util Config File:
#   location: ~/.scripts/bash_debug_utils.sh
#   author: t3@pfaffe.me  🄯2021-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Scripting functions for debuggin bash configurations



###################
### INITIALIZE: ###########################################################
###################

## Tag self as linked for dependents:
# shellcheck disable=2034
HAS_BASH_DEBUG_UTILS=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Define Used Files:
SRC_BASH_UTILS=~/.scripts/bash_utils.sh

## Script sourcing function:
# shellcheck disable=1090,2086
if ! command -v link_source &>/dev/null ; then link_source () { [[ -f $1 ]] && source $1 || echo "Failed to link ${1}!!"; } ; fi

## Link dependency:
#  shellcheck source=./bash_utils.sh
[ "$HAS_BASH_UTILS" = false ] && echo link_source $SRC_BASH_UTILS


###########################
### BASH_DEBUG_LOGGING: ###################################################
###########################

## Default options for log level:
safe_export USE_BASH_DEBUG_LVL_ERRORS true    # Critical ERRORS that *will* impact necessary functionality.
safe_export USE_BASH_DEBUG_LVL_WARNINGS false # Noncritical WARNINGS that *may* impact desired functionality.
safe_export USE_BASH_DEBUG_LVL_INFO true      # Noncritical INFO on the bash configuration that *wont* impact functionality.

## Define & initialize bash debug log:
var_exists DEBUG_ERROR_BASH_LOG   || declare -a DEBUG_ERROR_BASH_LOG
var_exists DEBUG_WARNING_BASH_LOG || declare -a DEBUG_WARNING_BASH_LOG
var_exists DEBUG_INFO_BASH_LOG    || declare -a DEBUG_INFO_BASH_LOG

## Default debug text colors:
export COLOR_ALRT='\e[1;31m'
export COLOR_WARN='\e[1;33m'
export COLOR_NC='\e[0m'

## Append argument to log
debug_append_log() {
    local arg
    [ $# -le 1 ] && return 1;
    arg="$1"; str_empty "$arg" && return 1 ; shift

    case $arg in
        -i|--info)
            DEBUG_INFO_BASH_LOG+=("$@")
        ;;
        -w|--warn)
            DEBUG_WARN_BASH_LOG+=("$@")
        ;;
        -e|--error)
            DEBUG_ERROR_BASH_LOG+=("$@")
        ;;
        *)
            echo "Warning ${arg} not a valid parameter!"
            return 1
        ;;
    esac ; return 0
}

## Append argument to log
debug_append_err() {
    local args="$*" ; str_empty "$args" && return 1
    DEBUG_ERROR_BASH_LOG+=("$args")
}

## Append argument to log
debug_append_warn() {
    local args="$*" ; str_empty "$args" && return 1
    DEBUG_WARN_BASH_LOG+=("$args")
}

## Append arguments to log
debug_append_info() {
    local args="$*" ; str_empty "$args" && return 1
    DEBUG_INFO_BASH_LOG+=("$args")
}

## Notify of an error in the bash configuration:
debug_notify_syntax_err() {
    debug_append_err "$(printf "[${COLOR_ALRT}Warning${COLOR_NC}]: Bash config file %s has errors!" "$1")"
}

## Notify of an error while linking another bash configuration file:
debug_notify_link_err() {
    debug_append_err "$(printf "[${COLOR_ALRT}Warning${COLOR_NC}]: Bash config file %s was not linked!" "$1")"
}

## Notify of an error while linking another non-vital bash configuration file:
debug_notify_link_warn() {
    debug_append_warn "$(printf "[${COLOR_WARN}Warning${COLOR_NC}]: Bash config file %s was not linked!" "$1")"
}

## Notify of some info that should be brought to attention:
debug_notify_info() {
    debug_append_info  "$(printf "[${COLOR_PRI}Notice${COLOR_NC}]: %s " "$1")"
}

## Notify of an change in the bash configuration:
notify_reload() {
    local args='' ; str_empty "$1" || local args="from file ${1}"
    debug_append_info "$(printf "[${COLOR_PRI}Notice${COLOR_NC}]: Reloaded bash configuration from %s." "$args")"
}

## Clears all debugging logs:
reset_debug_logs() {
    unset DEBUG_ERROR_BASH_LOG ; declare -ag DEBUG_ERROR_BASH_LOG
    unset DEBUG_WARNING_BASH_LOG ; declare -ag DEBUG_WARNING_BASH_LOG
    unset DEBUG_INFO_BASH_LOG ; declare -ag DEBUG_INFO_BASH_LOG
}


#########################
### BASH_DEBUG_TOOLS: #####################################################
#########################

## 'bash_lint' - Check syntax of bash config:
## usage: bash_lint <error(default) | warning | info | style>
##############################################################
bash_lint() {
    cmd_exists shellcheck || return 1
    if str_empty "$1" ; then local args='error' ; else local args="$1" ; fi
    shellcheck -S "$args" ~/.bash{rc,_!(*history)} && return 0 || return 1
}
##############################################################

## 'bash_lint_full' - Check syntax of bash config with more feedback:
## usage: bash_lint_full <error | warning(default) | info | style>
#####################################################################
bash_lint_full() {
    if str_empty "$1" ; then local args='warning' ; else local args="$1" ; fi
    printf "Checking bash config files for issues up to severity \'%s\'...\n" "$args"
    bash_lint "$args" && printf "\t<no issues found>"
    printf "\n done.\n"
    return 0
}
#####################################################################

## 'debug_bool_out' - inline boolean test:
## usage: debug_bool_out <bash_cmd>
##########################################
debug_bool_out() {
    local args=${*}
    if ( $args ) ; then
        printf "RETURNED=${COLOR_GREEN}%s${COLOR_NC}\n" "TRUE" ; return 0
    else
        printf "RETURNED=${COLOR_RED}%s${COLOR_NC}\n" "FAlSE" ; return 0
    fi
	echo "Failed to run command!" ; return 1
}
# Shortcut to boolean debug tool
alias debool="debug_bool_out"
##########################################
