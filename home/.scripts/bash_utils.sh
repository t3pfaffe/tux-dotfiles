#!/bin/bash
# bash_util Config File:
#   location: ~/.scripts/bash_utils.sh
#   author: t3@pfaffe.me  🄯2021-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Useful bash scripting functions



###################
### INITIALIZE: ###########################################################
###################

# Tag own existence for dependents
HAS_BASH_UTILS=true


#######################
### BASH_UTILITIES: #######################################################
#######################

## 'str_empty' - Checks if provided string(s) exist(s):
## usage: str_empty <variable_name>
######################################################
str_empty () {
    for arg in "$@" ; do [[ -z "${arg// }" ]] || return 1 ; done ; return 0
}
######################################################

## 'var_exists' - Checks if provided variable(s) exist:
## usage: var_exists <variable_name>
###################################################
var_exists () {
    str_empty "$1" && return 1
    for arg in "$@" ; do declare -p "$arg" &>/dev/null || return 1 ; done ; return 0
}

## 'cmd_exists' - Checks if provided command(s) exist:
## usage: cmd_exists <cmd>
######################################################
cmd_exists () {
    str_empty "$1" && return 1
    for arg in "$@" ; do command -v "$arg" >/dev/null || return 1 ; done ; return 0
}

## 'file_exists' - Checks if provided file(s) exist:
## usage: file_exists <file_path>
###################################################
file_exists () {
    str_empty "$1" && return 1
    for arg in "$@" ; do [ -f "$arg" ] >/dev/null || return 1 ; done ; return 0
}

## 'safe_export' - Only exports variable if doesnt already exist:
## usage: safe_export <variable_name> <new_value>
################################################################
safe_export () {
    if var_exists "$1"; then return 1
    else
        export "${1}=""${2}"
    fi
}
################################################################

## 'esc_str' - Performs proper string escapes for bash:
## usage: esc_str <strings>
######################################################
esc_str () {
  local arg="$*"
  local escapedvar=""

  if [[ "$2" == "--no-space" ]]; then
    escapedvar=$(echo "${arg}" | sed -e 's/[^][ a-zA-Z0-9/.:?,;(){}<>=*+-]/\\&/g' )
  else
    escapedvar=$(echo "${arg}" | sed -e 's/[^][a-zA-Z0-9/.:?,;(){}<>=*+-]/\\&/g'  )
  fi

  echo "${escapedvar}"
}
## [reference]( https://github.com/bitrise-io/steps-utils-bash-string-escaper/blob/master/bash_string_escape.sh )
######################################################
