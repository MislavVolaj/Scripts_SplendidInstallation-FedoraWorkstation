#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



BackUp_UserFolders() {
    # Checking for multiple users
    NUMBEROFUSERS=0

    for OUTPUT in $(cat /etc/passwd | grep "/home" | cut --delimiter=: --fields=1)
    do
        let NUMBEROFUSERS++
    done

    if [[ $NUMBEROFUSERS > 1 ]]
    then
        read -p "Would you like to back up other users' folders too? (y/ anything else to n): "

        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            # Iterating through all other users
            for USERSNAME in $(cat /etc/passwd | grep "/home" | cut --delimiter=: --fields=1)
            do
                echo "Backing up $USERSNAME's folders..."

                mkdir --parents "$WORKINGDIRECTORY"/$USERSNAME

                # Iterating through selected folders
                for FOLDER in ${BACKUPFOLDERS[@]}
                do
                    sudo rsync --archive --human-readable --info=progress2 /home/$USERSNAME/$FOLDER/ "$WORKINGDIRECTORY"/$USERSNAME/$FOLDER

                    echo "\"$FOLDER\" folder backing up script completed!"
                done
            done
        else
            echo "Backing up $USERNAME's folders..."

            mkdir --parents "$WORKINGDIRECTORY"/$USERNAME

            # Iterating through selected folders
            for FOLDER in ${BACKUPFOLDERS[@]}
            do
                rsync --archive --human-readable --info=progress2 $HOME/$FOLDER/ "$WORKINGDIRECTORY"/$USERNAME/$FOLDER

                echo "\"$FOLDER\" folder backing up script completed!"
            done
        fi
    else
        echo "Backing up $USERNAME's folders..."

        mkdir --parents "$WORKINGDIRECTORY"/$USERNAME

        # Iterating through selected folders
        for FOLDER in ${BACKUPFOLDERS[@]}
        do
            rsync --archive --human-readable --info=progress2 $HOME/$FOLDER/ "$WORKINGDIRECTORY"/$USERNAME/$FOLDER

            echo "\"$FOLDER\" folder backing up script completed!"
        done
    fi

    echo "Users' folders backing up script completed!"
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
