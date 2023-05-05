#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



Restore_UserFolders() {
    # Checking for multiple users
    NUMBEROFUSERS=0

    for OUTPUT in $(cat /etc/passwd | grep "/home" | cut --delimiter=: --fields=1)
    do
        let NUMBEROFUSERS++
    done

    if [[ $NUMBEROFUSERS > 1 ]]
    then
        read -p "Would you like to restore other users' folders too? (y/ anything else to n): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            # Iterating through all other users
            for USERSNAME in $(cat /etc/passwd | grep "/home" | cut --delimiter=: --fields=1)
            do
                echo "Restoring $USERSNAME's folders..."

                # Iterating through selected folders
                for FOLDER in ${RESTOREFOLDERS[@]}
                do
                    sudo rsync --archive --human-readable --info=progress2 "$WORKINGDIRECTORY"/$USERSNAME/$FOLDER /home/$USERSNAME/$FOLDER/

                    echo "\"$FOLDER\" folder restoring script completed!"
                done
            done
        else
            echo "Restoring $USERNAME's folders..."

                # Iterating through selected folders
            for FOLDER in ${RESTOREFOLDERS[@]}
            do
                rsync --archive --human-readable --info=progress2 "$WORKINGDIRECTORY"/$USERNAME/$FOLDER/ $HOME/$FOLDER

                echo "\"$FOLDER\" folder restoring script completed!"
            done
        fi
    else
        echo "Restoring $USERNAME's folders..."

        # Iterating through selected folders
        for FOLDER in ${RESTOREFOLDERS[@]}
        do
            rsync --archive --human-readable --info=progress2 "$WORKINGDIRECTORY"/$USERNAME/$FOLDER/ $HOME/$FOLDER

            echo "\"$FOLDER\" folder restoring script completed!"
        done
    fi

    echo "Users' folders restoring script completed!"
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
