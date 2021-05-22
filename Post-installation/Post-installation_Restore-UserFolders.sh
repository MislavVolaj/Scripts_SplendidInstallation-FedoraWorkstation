#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Restore_UserFolders() {
    echo "Restoring user folders..."

    for FOLDER in ${RESTOREFOLDERS[@]}
    do
        rsync --archive --human-readable --info=progress2 "$WORKINGDIRECTORY"/$(whoami)/$FOLDER/ $HOME/$FOLDER

        echo "\"$FOLDER\" folder restoring script completed!"
    done

    echo "User folders backing up script completed!"
}

Configure_UserFilesOwnership() {
    echo "Rebuilding user files ownership..."

    sudo chown --recursive $(whoami):$(whoami) $HOME $HOME/.[^.]*

    echo "Rebuilding user files ownership script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-8 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Restore \"Documents\" folder" "Restore \"Downloads\" folder" "Restore \"Music\" folder" "Restore \"Pictures\" folder" "Restore \"Videos\" folder" "Rebuild user files ownership"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                RESTOREFOLDERS=(Documents Downloads Music Pictures Videos)
                Restore_UserFolders
                Configure_UserFilesOwnership
                exit 0;;
            "Restore \"Documents\" folder" )
                RESTOREFOLDERS=(Documents)
                Restore_UserFolders
                Menu;;
            "Restore \"Downloads\" folder" )
                RESTOREFOLDERS=(Downloads)
                Restore_UserFolders
                Menu;;
            "Restore \"Music\" folder" )
                RESTOREFOLDERS=(Music)
                Restore_UserFolders
                Menu;;
            "Restore \"Pictures\" folder" )
                RESTOREFOLDERS=(Pictures)
                Restore_UserFolders
                Menu;;
            "Restore \"Videos\" folder" )
                RESTOREFOLDERS=(Videos)
                Restore_UserFolders
                Menu;;
            "Rebuild user files ownership" )
                Configure_UserFilesOwnership
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Pre-installation/Backup/"

Menu
