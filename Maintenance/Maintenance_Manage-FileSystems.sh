#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



CallScript_ManageFileSystems-EXT4() {
    echo "Calling EXT4 file system managing script..."

    chmod +x "$WORKINGDIRECTORY"/Manage_FileSystems-EXT4.sh
    "$WORKINGDIRECTORY"/./Manage_FileSystems-EXT4.sh

    echo "EXT4 file system managing script completed!"
}

CallScript_ManageFileSystems-XFS() {
    echo "Calling XFS managing script..."

    chmod +x "$WORKINGDIRECTORY"/Manage_FileSystems-XFS.sh
    "$WORKINGDIRECTORY"/./Manage_FileSystems-XFS.sh

    echo "XFS managing script completed!"
}

CallScript_ManageFileSystems-Btrfs() {
    echo "Calling Btrfs managing script..."

    chmod +x "$WORKINGDIRECTORY"/Manage_FileSystems-Btrfs.sh
    "$WORKINGDIRECTORY"/./Manage_FileSystems-Btrfs.sh

    echo "Btrfs managing script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Manage EXT4 file system" "Manage XFS" "Manage Btrfs"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                CallScript_ManageFileSystems-EXT4
                CallScript_ManageFileSystems-XFS
                CallScript_ManageFileSystems-Btrfs
                exit 0;;
            "Manage EXT4 file system" )
                CallScript_ManageFileSystems-EXT4
                Menu;;
            "Manage XFS" )
                CallScript_ManageFileSystems-XFS
                Menu;;
            "Manage Btrfs" )
                CallScript_ManageFileSystems-Btrfs
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
