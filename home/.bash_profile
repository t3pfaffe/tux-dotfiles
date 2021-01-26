#!/bin/bash
# bash_profile Config File:
#   location: ~/.bash_profile
#   author: t3@pfaffe.me  🄯2020-01/15/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    - first bash config file for loaded
#       interactive shells.



# If not running interactively, don't do anything
[[ $- != *i* ]] && return


###############################
### INITIALIZE_BASHPROFILE: ###############################################
###############################

#
SRC_BASHRC=~/.bashrc

## Link user aliases and functions
# shellcheck source=src/.bashrc
[[ -f ~/.bashrc ]] && source $SRC_BASHRC


####################################
### DEVELOPER-ENVIRONMENT-SETUP: ##########################################
####################################

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
source "$HOME/.cargo/env"
