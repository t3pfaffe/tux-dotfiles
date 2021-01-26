#!/bin/bash
# bash_profile Config File:
#   location: ~/.bash_profile
#   author: t3@pfaffe.me  🄯2020-01/26/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - Configuration (variable, alias, & function definitions) for login shells.
#    - Bash configuration heirachy:
#      (1) /etc/profile:    System-wide  config for strictly login shells.
#      (2) /etc/bashrc:     System-wide  config for shells.
#      (3) ~/.bash_profile: Profile-wide config for strictly login shells.
#      (4) ~/.bashrc:       Profile-wide config for shells.
#      (5) ~/.bash_logout:  Profile-wide config for shells that is executedon exit.
#       - Interactive/Login shells are for direct user interaction (e.x. terminals)
#       - Non-Interactive shells are launched by other programs
#      [src]( https://www.golinuxcloud.com/bashrc-vs-bash-profile/ )



###############################
### INITIALIZE_BASHPROFILE: ###############################################
###############################

# Tag self for dependents
HAS_BASH_PROFILE=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## Define Utilized Files:
SRC_BASHRC=~/.bashrc

## Link user aliases and functions:
# shellcheck source=src/.bashrc
[[ -f $SRC_BASHRC ]] && source $SRC_BASHRC || echo "Failed to link $SRC_BASHRC !!"

#########################
### AUTO-GEN_APPENDS: ######################################################
#########################
## Usually added by install scripts and appended to this file.
##

## ROS ENV Setup:
#################
# ROS_Noetic:
#source /opt/ros/noetic/setup.bash
#source /home/t3pfaffe/Projects/ROS-Learning/catkin_ws/devel/setup.bash

# ROS_ALL:
#export ROS_IP='127.0.0.1'
#export PATH="/home/t3pfaffe/.local/bin:/opt/ros/noetic/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/var/lib/flatpak/exports/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
#################

## Perl ENV Setup:
##################
# shellcheck disable=2090
PATH="/home/t3pfaffe/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/t3pfaffe/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/t3pfaffe/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base /home/t3pfaffe/perl5"; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/t3pfaffe/perl5"; export PERL_MM_OPT;
##################

## Rust ENV Setup:
source "$HOME/.cargo/env"
