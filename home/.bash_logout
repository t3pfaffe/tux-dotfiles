#!/bin/bash
# bash_logout Config File:
#   location:~/.bash_logout
#   author: t3@pfaffe.me  🄯2020-01/05/2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# If not running interactively, don't do anything
[[ $- != *i* ]] && return


###############################
### INITIALIZE_BASH_LOGOUT: ###############################################
###############################

## Define goodbye message
print_goodbye_msg () {
    echo "Goodbye!"
}


##############################
### CLOSE_UP_BASH_SESSION: ################################################
##############################

# Show goodbye message
trap print_goodbye_msg EXIT


#
## END_FILE
