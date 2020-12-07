# bash_profile Config File:
#   location: ~/.bash_profile
#   author: t3@pfaffe.me  2020-2020
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#Set Terminal
export TERMINAL="termite"

# Set Editor
export EDITOR='nano'
export VISUAL='micro'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#Get aliases and functions
[[ -f ~/.bashrc ]] && . ~/.bashrc

# ROS Noetic Setup:
source /opt/ros/noetic/setup.bash
source /home/t3pfaffe/Projects/ROS-Learning/catkin_ws/devel/setup.bash

# ROS ENV:
export ROS_IP='127.0.0.1'
export PATH="/home/t3pfaffe/.local/bin:/opt/ros/noetic/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/var/lib/flatpak/exports/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"

