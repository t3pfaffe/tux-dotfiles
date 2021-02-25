#!/bin/bash
# bash_util Config File:
#   location: ~/.scripts/bash_utils.sh
#   author: t3@pfaffe.me  🄯2021-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Useful bash scripting functions



###################
### INITIALIZE: ###########################################################
###################

## Tag self as linked for dependents:
# shellcheck disable=2034
HAS_BASH_UTILS=true


#######################
### BASH_UTILITIES: #######################################################
#######################

## 'str_empty' - Checks if provided string(s) is(are) empty:
## usage: str_empty <string>
############################################################
str_empty() {
    [ $# -le 0 ] && return 1; local arg
    for arg in "$@" ; do [[ -z "${arg// }" ]] || return 1 ; done ; return 0
}
############################################################

## 'str_exists' - Checks if provided string(s) exist(s):
## usage: str_exists <string>
########################################################
str_exists() {
    ! str_empty "$@"
}
########################################################

## 'var_exists' - Checks if provided variable(s) exist:
## usage: var_exists <variable_name>
#######################################################
var_exists () {
    [ $# -le 0 ] && return 1
    declare -p "$1" &>/dev/null && return 0 ; return 1
}
#######################################################

## 'get_inner_var' - Returns a variable's content given the name:
## usage: var_exists <variable_name>
#################################################################
get_inner_var() {
    [ $# -le 0 ] && return 1
    echo "${!1}" && return 0 ; return 1
}
#################################################################

## 'str_exists' - Checks if provided string(s) exist(s):
## usage: str_exists <variable_name>
########################################################
str_var_empty() {
    [ $# -le 0 ] && return 1
    if var_exists "$1" && str_empty "$( get_inner_var "$1" )" ; then return 0 ; else return 1 ; fi
}
########################################################

## 'str_var_exists' - Checks if provided string variable(s) exist(s):
## usage: str_exists <variable_name>
#####################################################################
str_var_exists() {
    [ $# -le 0 ] && return 1
    if var_exists "$1" && str_exists "$( get_inner_var "$1" )" ; then return 0 ; else return 1 ; fi
}
#####################################################################

## 'cmd_exists' - Checks if provided command(s) exist:
## usage: cmd_exists <cmd>
######################################################
cmd_exists() {
    str_empty "$1" && return 1 ; local arg
    for arg in "$@" ; do command -v "$arg" >/dev/null || return 1 ; done ; return 0
}

## 'dir_exists' - Checks if provided directory('s) exist:
## usage: file_exists <file_path>
#########################################################
dir_exists() {
    str_empty "$1" && return 1 ; local arg
    for arg in "$@" ; do [ -f "$arg" ] >/dev/null || return 1 ; done ; return 0
}
#########################################################

## 'file_exists' - Checks if provided file(s) exist:
## usage: file_exists <file_path>
###################################################
file_exists() {
    str_empty "$1" && return 1 ; local arg
    for arg in "$@" ; do [ -f "$arg" ] >/dev/null || return 1 ; done ; return 0
}
###################################################

## 'link_source' - Attempts to source provided file:
## usage: link_source <script_location>
####################################################
cmd_exists link_source && ( unset link_source ) ; link_source() {
    # shellcheck disable=2086
    str_empty $1 && ( echo "ERROR with 'link_source'! No argument given!"; return 1 ); local src="" ; src=$1    # define link location if arg is not empty
    # shellcheck disable=1090,2086,2015
    if cmd_exists file_exists ; then
        if cmd_exists debug_notify_link_err >/dev/null ; then file_exists $src && source ${src} || ( debug_notify_link_err "$src" ; return 1 )   # if bash_debug_utils is linked
        else file_exists ${src} && source ${src} || ( echo "Failed to link $src !!" ; return 1 ) fi;        # if only bash_utils is linked
    else [[ -f $src ]] && source $src || ( echo "Failed to link $src !!" ; return 1 ) ; fi ; return 0   # if no utils are linked
}
####################################################

## 'safe_export' - Only exports variable if doesnt already exist:
## usage: safe_export <variable_name> <new_value>
################################################################
safe_export () {
    if var_exists "$1" ; then return 1
    else export "${1}=""${2}" ; fi
}
################################################################

## 'esc_str' - Performs proper string escapes for bash:
## usage: esc_str <strings>
######################################################
esc_str() {
  local arg="$*"
  local escapedvar=""

  if [[ "$2" == "--no-space" ]] ; then
    escapedvar=$(echo "${arg}" | sed -e 's/[^][ a-zA-Z0-9/.:?, ;(){}<>=*+-]/\\&/g' )
  else
    escapedvar=$(echo "${arg}" | sed -e 's/[^][a-zA-Z0-9/.:?, ;(){}<>=*+-]/\\&/g'  )
  fi

  echo "${escapedvar}"
}
## [reference]( https://github.com/bitrise-io/steps-utils-bash-string-escaper/blob/master/bash_string_escape.sh )
######################################################
