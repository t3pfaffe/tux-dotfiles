#!/bin/sh
# Bash_utils Unit Testing Script:
#   location: ~/Documents/Scripts/Public/bash_utils.tests.sh
#   author: t3@pfaffe.me    🄯2020-01.31.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

# Define this script's name
SCRIPT_NAME="bash_utils.tests"

## Example Variables:
START_TIME=$(date +%m/%d/%C-%H:%M)
TIME_ZONE=$(date +%Z)


#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Common function definitions.

show_usage() {
    printf "Usage: %s [OPTIONS]" "$SCRIPT_NAME"

    printf "\n\nScript for testing the propper functionality of 'bash_utils.sh'."

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

## Check for parameters/options:
if [ $# -eq 0 ] ; then ## Default behaviour with no args:
    printf ""
    ## Un-comment if script requires an argument
    #show_usage; exit 0
else
    for i in "$@" ; do
        case $i in
            -h|--help)
                show_usage; exit 0
            ;;
            *-[!\ ]*)
                printf "%s: invalid option '%s'\n" "$SCRIPT_NAME" "$1"
                printf "Try '%s --help' for more information.\n" "$SCRIPT_NAME"
                shift; exit 1
            ;;
        esac
    done
fi

## Example execution cmds:
printf 'This is an example script. For demonstration purposes...\n'
printf '	the current system time is %s \n' "$START_TIME $TIME_ZONE"

## TODO: make this a thing!

#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.


#
# FILE_END
