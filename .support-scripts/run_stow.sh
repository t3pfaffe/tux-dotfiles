#!/bin/sh
# Stow Deployment Script:
#   location: <.git>/.support-scripts/run_stow.sh
#   author: t3@pfaffe.me    🄯2020-01.05.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

# Define this script's name
SCRIPT_NAME="run_stow"

#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Common function definitions.

show_usage() {
    printf "Usage: %s [OPTIONS]" "$SCRIPT_NAME"

    printf "\n\nScript for stow deployment operations from tux-dotfiles repository."

    #Show options/parameters
    printf "\n"
    printf "\nOptions: "
    printf "\n  -h, --help \n\t\tShow this message and exit."

    #End statement
    printf "\n"
}

#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

printf "Checking for local updates and running stow to pull anything new from the git repo... \n"

stow home/ --target=/home/$USER/ || printf "If failed try adoting existing files with \' stow home/ --target=/home/$USER/ --adopt\' \n"; exit 1

#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.

exit 0;


#
# FILE_END
