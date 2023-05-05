#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



ManageXFS_Scrub() {
    echo "Scrubbing XFS file systems..."

    for XFSFILESYSTEMMOUNTPOINT in $(findmnt --types xfs --output "TARGET" --noheadings --list)
    do
        # Checking integrity of the metadata objects and automatically repairing from other metadata if there exists redundant data structures which are intact
        sudo xfs_scrub $XFSFILESYSTEMMOUNTPOINT && echo "XFS file system mounted at $XFSFILESYSTEMMOUNTPOINT scrubbing completed!"
    done

    echo "XFS file systems scrubbing script completed!"
}

ManageXFS_Repair() {
    echo "Repairing XFS file systems..."

    for XFSFILESYSTEMMOUNTPOINT in $(findmnt --types xfs --output "SOURCE" --noheadings --list)
    do
        sudo umount $XFSFILESYSTEMMOUNTPOINT

        # Checking and repairing corrupt or damaged inode, inode blockmap, inode allocation map, inode size, directories, pathnames, link counts, freemap and super blocks
        sudo xfs_repair $XFSFILESYSTEMMOUNTPOINT && echo "XFS file system mounted at $XFSFILESYSTEMMOUNTPOINT repairing completed!"

        sudo mount $XFSFILESYSTEMMOUNTPOINT
    done

    echo "XFS file systems repairing script completed!"
}

ManageXFS_Defragment() {
    echo "Defragmenting XFS file systems..."

    for XFSFILESYSTEMMOUNTPOINT in $(findmnt --types xfs --output "TARGET" --noheadings --list)
    do
        # Merging file extents in the file system 
        sudo xfs_fsr && echo "XFS file system mounted at $XFSFILESYSTEMMOUNTPOINT defragmenting completed!"
    done

    echo "XFS file systems defragmenting script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-5 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Scrub" "Repair" "Defragment"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                ManageXFS_Scrub
                ManageXFS_Repair
                ManageXFS_Defragment
                exit 0;;
            "Scrub" )
                ManageXFS_Scrub
                Menu;;
            "Repair" )
                ManageXFS_Repair
                Menu;;
            "Defragment" )
                ManageXFS_Defragment
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
