#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



BackUp_UserFolders() {
    echo "Backing up user folders..."

    mkdir --parents "$WORKINGDIRECTORY"/$(whoami)

    for FOLDER in ${BACKUPFOLDERS[@]}
    do
        rsync --archive --human-readable --info=progress2 $HOME/$FOLDER/ "$WORKINGDIRECTORY"/$(whoami)/$FOLDER

        echo "\"$FOLDER\" folder backing up script completed!"
    done

    echo "User folders backing up script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-7 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Back up \"Documents\" folder" "Back up \"Downloads\" folder" "Back up \"Music\" folder" "Back up \"Pictures\" folder" "Back up \"Videos\" folder"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                BACKUPFOLDERS=(Documents Downloads Music Pictures Videos)
                BackUp_UserFolders
                exit 0;;
            "Back up \"Documents\" folder" )
                BACKUPFOLDERS=(Documents)
                BackUp_UserFolders
                Menu;;
            "Back up \"Downloads\" folder" )
                BACKUPFOLDERS=(Downloads)
                BackUp_UserFolders
                Menu;;
            "Back up \"Music\" folder" )
                BACKUPFOLDERS=(Music)
                BackUp_UserFolders
                Menu;;
            "Back up \"Pictures\" folder" )
                BACKUPFOLDERS=(Pictures)
                BackUp_UserFolders
                Menu;;
            "Back up \"Videos\" folder" )
                BACKUPFOLDERS=(Videos)
                BackUp_UserFolders
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Backup/"

Menu
