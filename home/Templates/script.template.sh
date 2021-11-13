#!/bin/sh
# <$SCRIPT_NAME> Script:
#   location: ~/Documents/Scripts/<$SCRIPT_NAME>.sh
#   author: t3@pfaffe.me    🄯2020-05.17.2021
#   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Other notes/references:
#    [link]( https://github.com/t3pfaffe )


#####################
### SCRIPT_SETUP: #########################################################
#####################
## Defining default variable states and other setup configurations.

# Define this script's name
# TODO: Refactor <$SCRIPT_NAME> to desired script name (Including the <...> endcaps!)
# SCRIPT_NAME="<$SCRIPT_NAME>"

## Example Parameter Toggles:
DO_QUIET=false      # Suppress cmd outputs.

## Example Initial Variables:
START_TIME=$(date +%m/%d/%C-%H:%M)
TIME_ZONE=$(date +%Z)


#########################
### DEFINE_FUNCTIONS: #####################################################
#########################
## Common function definitions.

show_usage() {
    printf "Usage:\t%s [OPTIONS]" "$SCRIPT_NAME"

    printf "\n\nDescription:\tBase template for shell scripts. This is an example script for example purposes."

    #Show options/parameters
    printf "\n"
    printf "\nOptions: "
    printf "\n  -h, --help  \n\t\tShow this message and exit."
    printf "\n  -q, --quiet \n\t\tSuppresses command outputs."

    #End statement
    printf "\n"
}

try_printf() {
    # shellcheck disable=2059
    "$DO_QUIET" || printf "$@";
}


#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

## Check for parameters/options:
if [ $# -ge 1 ]; then   ## Check for valid parameters & set vars accordingly:
    for i in "$@"; do case $i in
        -q|--quiet) DO_QUIET=true;  shift;;
        -h|--help)  show_usage;    exit 0;;
        *-[!\ ]*|*--[!\ ]*) printf "Error: '%s' is not a valid parameter!\n" "${1}"; return 1;;
    esac; done;
else                    ## Perform default no-args behaviour:
    printf ""               # Empty-block 'blank' cmd to satisfy if/else syntax.
    #show_usage; exit 0     # TODO: Un-comment line if at least one arg is required.
fi

## Example execution cmds:
try_printf "This is an example script. For demonstration purposes...\n\t"
try_printf "the current system time is %s \n" "${START_TIME} ${TIME_ZONE}"

#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.


#
# FILE_END
