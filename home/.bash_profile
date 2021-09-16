#!/bin/bash
# bash_profile Config File:
#   location: ~/.bash_profile
#   author: t3@pfaffe.me  🄯2020-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Configuration (variable, alias, & function definitions) for login shells.
#    - Bash configuration heirachy:
#      (1) //etc/profile:   System-wide  config for strictly login shells.
#      (2) //etc/bashrc:    System-wide  config for shells.
#      (3) ~/.bash_profile: Profile-wide config for strictly login shells.
#      (4) ~/.bashrc:       Profile-wide config for shells.
#      (5) ~/.bash_logout:  Profile-wide config for shells that is executed on exit.
#       - Interactive/Login shells are for direct user interaction (e.x. terminals)
#       - Non-Interactive shells are launched by other programs
#      [src]( https://www.golinuxcloud.com/bashrc-vs-bash-profile/ )



###############################
### INITIALIZE_BASHPROFILE: ###############################################
###############################

## Ignore these error codes globally:
#shellcheck disable=SC2059

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Tag self as linked for dependents:
# shellcheck disable=2034
HAS_BASH_PROFILE=true

## Define Utilized Files:
SRC_BASHRC=~/.bashrc

## Script sourcing function:
# shellcheck disable=1090,2086
if ! command -v link_source &>/dev/null ; then link_source () { [[ -f $1 ]] && source $1 || echo "Failed to link ${1}!!"; } ; fi

## Link user aliases and functions:
# shellcheck source=./.bashrc
link_source $SRC_BASHRC

#####################
### LINK_APPENDS: ##########################################################
#####################
## Usually added by install scripts and appended to this file.
##

## Disable bash_lint from following sources
# shellcheck disable=SC1091

## Rust ENV Setup:
cmd_exists cargo && link_source "$HOME/.cargo/env" && export CARGO_HOME="$HOME/.cargo/"

## Ruby ENV Setup:
cmd_exists ruby && GEM_HOME="$(ruby -e 'puts Gem.user_dir')" && export GEM_HOME && export PATH="$PATH:$GEM_HOME/bin"
