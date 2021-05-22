#!/bin/bash

# "Splendid installation" scripts for Fedora Workstation
# Copyright (C) 2021 Mislav Volaj
# Read full copyright notices by viewing the source code of the main menu script or by running it



CallScript_Update() {
    echo "Calling software updating script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_Update.sh
    "$WORKINGDIRECTORY"/./Maintenance_Update.sh

    echo "Software updating script completed!"
}

CallScript_CleanUp() {
    echo "Calling cleaning up script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_CleanUp.sh
    "$WORKINGDIRECTORY"/./Maintenance_CleanUp.sh

    echo "Cleaning up script completed!"
}

CallScript_XFS-Manage() {
    echo "Calling XFS managing script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_XFS-Manage.sh
    "$WORKINGDIRECTORY"/./Maintenance_XFS-Manage.sh

    echo "XFS managing script completed!"
}

CallScript_Btrfs-Manage() {
    echo "Calling Btrfs managing script..."

    chmod +x "$WORKINGDIRECTORY"/Maintenance_Btrfs-Manage.sh
    "$WORKINGDIRECTORY"/./Maintenance_Btrfs-Manage.sh

    echo "Btrfs managing script completed!"
}



Menu() {
    echo

    PS3="Press 1 to exit, 2 to run all options or 3-6 to select an option to run: "

    select options in "EXIT" "RUN ALL OPTIONS" "Update" "Clean up" "Manage XFS" "Manage Btrfs"; do
        case "$options" in
            "EXIT" )
                exit 0;;
            "RUN ALL OPTIONS" )
                CallScript_Update
                CallScript_CleanUp
                CallScript_XFS-Manage
                CallScript_Btrfs-Manage
                exit 0;;
            "Update" )
                CallScript_Update
                Menu;;
            "Clean up" )
                CallScript_CleanUp
                Menu;;
            "Manage XFS" )
                CallScript_XFS-Manage
                Menu;;
            "Manage Btrfs" )
                CallScript_Btrfs-Manage
                Menu;;
        esac
    done
}



COLUMNS=1
WORKINGDIRECTORY="$(pwd)/Maintenance"

Menu
