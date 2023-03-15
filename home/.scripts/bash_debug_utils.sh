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
safe_declare USE_BASH_DEBUG_LVL_ERRORS '=true'      # Critical ERRORS that *will* impact necessary functionality.
safe_declare USE_BASH_DEBUG_LVL_WARNINGS '=false'   # Non-critical WARNINGS that *may* impact desired functionality.
safe_declare USE_BASH_DEBUG_LVL_INFO '=true '       # Non-critical INFO on the bash configuration that *wont* impact functionality.

## Define & initialize bash debug log:
var_exists DEBUG_ERR_BASH_LOG || declare -a DEBUG_ERR_BASH_LOG
var_exists DEBUG_WRN_BASH_LOG || declare -a DEBUG_WRN_BASH_LOG
var_exists DEBUG_INF_BASH_LOG || declare -a DEBUG_INF_BASH_LOG

## Default debug text colors:
safe_export COLOR_INFO $COLOR_PRI
safe_export COLOR_WARN '\e[1;33m'
safe_export COLOR_ALRT '\e[1;31m'
safe_export COLOR_NC   '\e[0m'

## Debug msg buffer operations:
###############################

## 'debug_append_log' - Appends msg to specific severity log:
## usage: debug_append_log -<severity> <message>
#############################################################
debug_append_log() {
    [ $# -lt 1 ] && return 1; local arg
    arg="$1"; str_empty "$arg" && return 1 ; shift

    case $arg in
        -i|--info)  $USE_BASH_DEBUG_LVL_INFO     &&  DEBUG_INF_BASH_LOG+=("$*");;
        -w|--warn)  $USE_BASH_DEBUG_LVL_WARNINGS &&  DEBUG_WRN_BASH_LOG+=("$*");;
        -e|--error) $USE_BASH_DEBUG_LVL_ERRORS   &&  DEBUG_ERR_BASH_LOG+=("$*");;
        *) printf "Warning %s not a valid parameter!\n" "${arg}"; return 1;;
    esac ; return 0
}
#############################################################

## Append arguments to info log:
debug_append_inf() {
    $USE_BASH_DEBUG_LVL_INFO || return 0
    str_empty "$*" && return 1
    DEBUG_INF_BASH_LOG+=("$*")
}

## Append argument to warnings log:
debug_append_wrn() {
    $USE_BASH_DEBUG_LVL_WARNINGS || return 0;
    str_empty "$*" && return 1
    DEBUG_WRN_BASH_LOG+=("$*")
}

## Append argument to errors log:
debug_append_err() {
    $USE_BASH_DEBUG_LVL_ERRORS || return 0
    str_empty "$*" && return 1
    DEBUG_ERR_BASH_LOG+=("$*")
}

## Clears all debugging logs:
reset_debug_logs() {
    unset DEBUG_INF_BASH_LOG ; declare -ag DEBUG_INF_BASH_LOG
    unset DEBUG_WRN_BASH_LOG ; declare -ag DEBUG_WRN_BASH_LOG
    unset DEBUG_ERR_BASH_LOG ; declare -ag DEBUG_ERR_BASH_LOG
}
###############################

## Debug msg templates/shortcuts:
#################################

## Notify of some info that should be brought to attention:
debug_notify_info() {
    debug_append_inf "$(printf "[${COLOR_PRI}Notice${COLOR_NC}]:  %s " "${1}")"
}

## Notify of some info that should be brought to attention:s
debug_notify_warn() {
    debug_append_wrn "$(printf "[${COLOR_WARN}Warning${COLOR_NC}]: %s " "${1}")"
}

## Notify of some info that should be brought to attention:
debug_notify_error() {
    debug_append_err "$(printf "[${COLOR_ALRT}Error${COLOR_NC}]:   %s " "${1}")"
}

## Specific Type Templates:
    ## Notify of an change in the bash configuration:
    notify_info_reload() {
        local args=""; str_empty "$1" || args=" from file ${1}"
        # debug_append_inf "$(printf "[${COLOR_PRI}Notice${COLOR_NC}]:  Reloaded bash configuration%s." "${args}")"
        debug_notify_info "Reloaded bash configuration${args}."
    }

    ## Notify of an error while linking another non-vital bash configuration file:
    debug_notify_link_wrn() {
        debug_append_wrn "$(printf "[${COLOR_WARN}Warning${COLOR_NC}]: Bash config file %s was not linked!" "$*")"
        # debug_notify_wrn "Bash config file ${*} was not linked!"
    }

    ## Notify of an error while linking another bash configuration file:
    debug_notify_link_err() {
        debug_append_err "$(printf "[${COLOR_ALRT}Error${COLOR_NC}]:   Bash config file %s was not linked!" "$*")"
        # debug_notify_err "Bash config file ${*} was not linked!"
    }

    ## Notify of an error in the bash configuration:
    debug_notify_syntax_err() {
        debug_append_err "$(printf "[${COLOR_ALRT}Error${COLOR_NC}]:   Bash config file %s has errors!" "$*")"
        # debug_notify_err "Bash config file ${*} has errors!"
    }
##
################################


#########################
### BASH_DEBUG_TOOLS: #####################################################
#########################

#------
#### 'bash_lint' - Check syntax of bash config:
#&emsp; **usage:** bash_lint <error(default) | warning | info | style>
#<!--#########################################################
bash_lint() {
    cmd_exists shellcheck || return 1
    if str_empty "$1" ; then local args='error' ; else local args="$1" ; fi
    shellcheck -S "$1" ~/.bash{rc,_!(*history)} && return 0 || return 1
}
#<!--#########################################################

#------
#### 'bash_lint_full' - Check syntax of bash config with more feedback:
#&emsp; **usage:** bash_lint_full <error | warning(default) | info | style>
#<!--################################################################
bash_lint_full() {
    if str_empty "$1" ; then local args='warning' ; else local args="$1" ; fi
    printf "Checking bash config files for issues up to severity \'%s\'...\n" "$1"
    bash_lint "$1" && printf "\t<no issues found>"
    printf "\n done.\n"
    return 0
}
#<!--################################################################

#------
#### 'debug_bool_out' - inline boolean test:
#&emsp; **usage:** debug_bool_out <bash_cmd>
#<!--#####################################
debug_bool_out() {
    [ $# -lt 1 ] && return 1; local args=${*}

    if ( $args ) ; then
        printf "RETURNED=${COLOR_GREEN}%s${COLOR_NC}\n" "TRUE" ; return 0
    else
        printf "RETURNED=${COLOR_RED}%s${COLOR_NC}\n" "FAlSE" ; return 0
    fi
	echo "Failed to run command!" ; return 1
} ; alias debool="debug_bool_out"
#<!--#####################################

#
## END_FILE
