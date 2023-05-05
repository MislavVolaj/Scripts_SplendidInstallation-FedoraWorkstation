#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



ManageEXT4_Repair() {
    echo "Repairing EXT4 file systems..."

    # Checking and repairing all EXT4 file systems
    for EXT4FILESYSTEMMOUNTPOINT in $(findmnt --types ext4 --output "SOURCE" --noheadings --list)
    do
        sudo umount $EXT4FILESYSTEMMOUNTPOINT

        sudo e2fsck -f -p $EXT4FILESYSTEMMOUNTPOINT && echo "EXT4 file system mounted at $EXT4FILESYSTEMMOUNTPOINT repairing completed!"

        sudo mount $EXT4FILESYSTEMMOUNTPOINT
    done

    echo "EXT4 file systems repairing script completed!"
}

ManageEXT4_Defragment() {
    echo "Defragmenting EXT4 file systems..."

    # Merging file extents in the file system
    for EXT4FILESYSTEMMOUNTPOINT in $(findmnt --types ext4 --output "SOURCE" --noheadings --list)
    do
        sudo e4defrag $EXT4FILESYSTEMMOUNTPOINT && echo "EXT4 file system mounted at $EXT4FILESYSTEMMOUNTPOINT defragmenting completed!"
    done

    echo "EXT4 file systems defragmenting script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-4 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Repair" "Defragment"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                ManageEXT4_Repair
                ManageEXT4_Defragment
                exit 0;;
            "Repair" )
                ManageEXT4_Repair
                Menu;;
            "Defragment" )
                ManageEXT4_Defragment
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
