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

## Define default script operation params:
DRY_RUN=false
UPDATE_LINKS=false
ADOPT_EXISTING=false
TARGET_DIR="/home/$USER/"
SOURCE_DIR="$(git rev-parse --show-toplevel 2>/dev/null )/home/*" || SOURCE_DIR="$(pwd)"

# Define default stow params:
STOW_PARAMS="--dir=${SOURCE_DIR} --target=${TARGET_DIR}"


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
    printf "\n  -A --adopt \n\t\tAdopts existing files from target."
    printf "\n  -U --update  \n\t\tRuns stow to add new symlinks or prune removed ones"
    printf "\n  -D --deploy  \n\t\tRuns stow to deploy symlinks to target directories"
    printf "\n     --dry-run \n\t\t"

    #End statement
    printf "\n"
}

stow_deploy() {
    printf "Checking for local updates and running stow to pull anything new from the git repo... \n"

    execute_stow || printf "It looks like the operation failed. Perhaps try adopting existing files with \'--adopt\'."; exit 1
}

execute_stow() {

    # Apply adopt param
    $ADOPT_EXISTING && STOW_PARAMS="--adopt ${STOW_PARAMS}"

    # Apply update-links param
    $UPDATE_LINKS && STOW_PARAMS="--restow ${STOW_PARAMS}"

    # Apply dry-run param
    $DRY_RUN && STOW_PARAMS="--simulate ${STOW_PARAMS}"

    /usr/bin/stow "$STOW_PARAMS"
}

#######################
### EXECUTE_SCRIPT: #######################################################
#######################
## Execute script linearly from this point.

## Check for parameters/options:
if [ $# -eq 0 ] ; then ## Default behaviour with no args:
    printf ""
    ## Un-comment if script requires an argument to function
    #show_usage; exit 0
else
    for i in "$@" ; do
        case $i in
            -h|--help)
                show_usage; exit 0
            ;;
            --dry-run)
                DRY_RUN=true
            ;;
            -A| --adopt)
                ADOPT_EXISTING=true
            ;;
            -U| --update)
                UPDATE_LINKS=true
            ;;
            -D| --deploy)
                stow_deploy
            ;;
            *-[!\ ]*)
                printf "%s: invalid option '%s'\n" "$SCRIPT_NAME" "$1"
                printf "Try '%s --help' for more information.\n" "$SCRIPT_NAME"
                shift; exit 1
            ;;
        esac
    done
fi


#######################
### SCRIPT_CLEANUP: #######################################################
#######################
## Cleanup vars and backround proccesss from script execution.

exit 0;


#
# FILE_END
